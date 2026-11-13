#!/usr/bin/env python3
"""Pruebas de estructura de documentclass.

Compila cada archivo de test/ y demos/ y revisa el PDF resultante:

  - compila sin errores;
  - ninguna página lleva solo un folio (una página en blanco que debía quedar vacía);
  - los folios crecen: romanos en el front matter, arábigos después;
  - ninguna línea de texto se solapa con otra (índices pegados a la línea anterior);
  - en `structure_book.typ`: las páginas vacías son versos, cada verso lleva la parte y cada
    recto el capítulo vigentes, las aperturas no llevan cabecera y el índice lista los capítulos;
  - el texto de cada página coincide con el de test/reference/ (solo los archivos con
    referencia; hay que regenerarlas con --update tras un cambio intencionado).

Se compila con --ignore-system-fonts: así el resultado no depende de las fuentes instaladas.
Los archivos que piden otras fuentes salen con su fallback; no tienen referencia.

Uso, desde la raíz del paquete:
  python3 test/structure.py                 todo
  python3 test/structure.py -k front_order  solo los archivos que contengan el texto
  python3 test/structure.py --update        regenera test/reference/
  python3 test/structure.py --no-reference  sin comparar con las referencias
Requiere `typst` y `pdftotext` (poppler-utils).
"""

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "test" / "reference"

# No son documentos que compilar: módulos, datos, resultados
SKIP = {"my-custom-titlepage.typ"}

# Archivos con texto de referencia: solo fuentes incluidas con Typst
REFERENCED = {
    "demos/demo_book.typ",
    "demos/demo_report.typ",
    "demos/demo_article.typ",
    "test/front_order.typ",
    "test/blank_pagebreaks.typ",
    "test/structure_book.typ",
}

# La capitular es más alta que su línea y se solapa con ella por diseño
NO_OVERLAP_CHECK = {"test/dropcaps.typ"}

ROMAN = re.compile(r"^[ivxlcdm]+$")
ARABIC = re.compile(r"^\d+$")

failures: list[str] = []


def fail(name: str, message: str) -> None:
    failures.append(f"{name}: {message}")
    print(f"  FALLA {message}")


def compile_pdf(source: Path, out: Path) -> str | None:
    """Compila; devuelve el mensaje de error o None."""
    run = subprocess.run(
        ["typst", "compile", "--root", str(ROOT), "--ignore-system-fonts", str(source), str(out)],
        capture_output=True,
        text=True,
    )
    if run.returncode != 0:
        return run.stderr.strip().splitlines()[0] if run.stderr.strip() else "error desconocido"
    return None


def pages_text(pdf: Path) -> list[str]:
    text = subprocess.run(["pdftotext", "-layout", str(pdf), "-"], capture_output=True, text=True, check=True).stdout
    pages = text.split("\f")
    if pages and not pages[-1].strip():
        pages.pop()  # pdftotext termina con un salto de página
    return pages


def lines_of(page: str) -> list[str]:
    return [line.strip() for line in page.splitlines() if line.strip()]


def folio_of(page: str, total: int = 9999) -> str | None:
    """Folio: la última línea si es solo un número arábigo o romano. Con `total`, un número
    mayor que las páginas del documento (un año en la portada) no cuenta."""
    lines = lines_of(page)
    if not lines:
        return None
    last = lines[-1]
    if ARABIC.match(last) and int(last) <= total:
        return last
    if ROMAN.match(last) and roman_value(last) <= total:
        return last
    return None


def check_folio_only(name: str, pages: list[str]) -> None:
    """Una página con solo su folio es una página en blanco que no debía llevarlo."""
    for n, page in enumerate(pages, 1):
        lines = lines_of(page)
        if len(lines) == 1 and folio_of(page, len(pages)) is not None:
            fail(name, f"la página {n} solo tiene el folio «{lines[0]}»")


def roman_value(s: str) -> int:
    values = {"i": 1, "v": 5, "x": 10, "l": 50, "c": 100, "d": 500, "m": 1000}
    total = 0
    for a, b in zip(s, s[1:] + " "):
        v = values[a]
        total += -v if b in values and values[b] > v else v
    return total


def check_folios(name: str, pages: list[str]) -> None:
    """Los folios romanos y arábigos crecen a lo largo del documento."""
    for kind, pattern, value in (("romanos", ROMAN, roman_value), ("arábigos", ARABIC, int)):
        last = 0
        for n, page in enumerate(pages, 1):
            folio = folio_of(page, len(pages))
            if folio is None or not pattern.match(folio):
                continue
            current = value(folio)
            if current <= last:
                fail(name, f"folio {kind} fuera de orden en la página {n}: «{folio}» tras {last}")
            last = current


LINE = re.compile(r'<line xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</line>', re.S)


def bbox_pages(pdf: Path) -> list[list[tuple[float, float, float, float, str]]]:
    """Líneas de cada página como (x0, y0, x1, y1, texto), según pdftotext -bbox-layout."""
    html = subprocess.run(
        ["pdftotext", "-bbox-layout", str(pdf), "-"], capture_output=True, text=True, check=True
    ).stdout
    pages = []
    for page in re.split(r"<page ", html)[1:]:
        boxes = []
        for m in LINE.finditer(page):
            x0, y0, x1, y1 = map(float, m.groups()[:4])
            words = re.findall(r">([^<]*)</word>", m.group(5))
            boxes.append((x0, y0, x1, y1, " ".join(words)))
        pages.append(boxes)
    return pages


def geometry_of(pdf: Path) -> list[str]:
    """Posición de cada línea, redondeada a 0.5 pt: detecta cambios de márgenes e interlineado."""
    out = []
    for n, boxes in enumerate(bbox_pages(pdf), 1):
        out.append(f"== página {n}")
        out.extend(f"{round(x0 * 2) / 2:g} {round(y0 * 2) / 2:g} {round(x1 * 2) / 2:g}" for x0, y0, x1, _, _ in boxes)
    return out


def check_overlap(name: str, pdf: Path) -> None:
    """Dos líneas de texto no deben solaparse (índices pegados, líneas montadas)."""
    for n, boxes in enumerate(bbox_pages(pdf), 1):
        for i, a in enumerate(boxes):
            for b in boxes[i + 1 :]:
                x_overlap = min(a[2], b[2]) - max(a[0], b[0])
                y_overlap = min(a[3], b[3]) - max(a[1], b[1])
                smaller = min(a[3] - a[1], b[3] - b[1])
                if x_overlap > 2 and smaller > 0 and y_overlap > 0.6 * smaller:
                    fail(name, f"página {n}: «{a[4][:30]}» se solapa con «{b[4][:30]}»")


def check_structure_book(name: str, pages: list[str]) -> None:
    """Cabeceras y páginas en blanco de `classic` en test/structure_book.typ."""
    parts = ["ParteUno", "ParteDos"]
    chapters = ["CapituloAlfa", "CapituloBeta", "CapituloGamma", "Bibliografia"]
    part, chapter, seen = None, None, set()
    next_part = 0
    for n, page in enumerate(pages, 1):
        lines = lines_of(page)
        if not lines:
            if n % 2 == 1:
                fail(name, f"la página {n} es un recto en blanco")
            continue
        first = lines[0]
        if first.startswith("PA R T E") or first.startswith("PARTE"):  # apertura de parte
            part = parts[next_part] if next_part < len(parts) else part
            next_part += 1
            if folio_of(page) is not None:
                fail(name, f"la apertura de parte (página {n}) lleva folio")
            continue
        if first.startswith("CAPÍTULO"):  # apertura de capítulo: sin cabecera, con folio
            chapter = next((c for c in chapters if c in lines[:3]), chapter)
            seen.add(chapter)
            if folio_of(page) is None:
                fail(name, f"la apertura de capítulo (página {n}) no lleva folio")
            continue
        if first in chapters and first not in seen:  # capítulo sin número (bibliografía)
            chapter = first
            seen.add(first)
            continue
        # Páginas con cabecera: solo en el cuerpo, que tiene folio arábigo y parte vigente
        folio = folio_of(page)
        if part is None or folio is None or not ARABIC.match(folio):
            if first in parts or first in chapters:
                fail(name, f"la página {n} lleva cabecera «{first}» antes del cuerpo")
            continue
        expected = part if n % 2 == 0 else chapter
        if first != expected:
            fail(name, f"página {n}: la cabecera es «{first}» y debía ser «{expected}»")
    contents = " ".join(pages[:6])
    for title in chapters[:3]:
        if title not in contents:
            fail(name, f"el índice no lista «{title}»")


def check_no_date(name: str, pages: list[str]) -> None:
    """Un ensayo sin `date` no lleva fecha en la cabecera: ningún año en las primeras líneas."""
    for n, page in enumerate(pages, 1):
        head = " ".join(lines_of(page)[:2])
        if re.search(r"\b20\d\d\b", head):
            fail(name, f"la página {n} lleva una fecha en la cabecera: «{head[:60]}»")


def check_verify(name: str, pages: list[str], visible: bool) -> None:
    """`verify[…]` es invisible para el lector y se ve con `debug: (verify: true)`; en los dos casos la consulta
    `<dc-verify>` devuelve las marcas con su página."""
    text = " ".join(pages)
    if visible and "VERIFICAR" not in text:
        fail(name, "con debug las marcas verify no se ven")
    if not visible and "VERIFICAR" in text:
        fail(name, "sin debug las marcas verify son visibles para el lector")
    run = subprocess.run(
        ["typst", "eval", "--root", str(ROOT), "query(<dc-verify>).map(it => it.value.page)", "--in", str(ROOT / name)],
        capture_output=True,
        text=True,
    )
    if run.returncode != 0 or run.stdout.strip() != "[1,1]":
        fail(name, f"la consulta <dc-verify> no devuelve las dos marcas: {run.stdout.strip() or run.stderr.strip()[:80]}")


def check_reference(name: str, source: str, pages: list[str], pdf: Path, update: bool) -> None:
    """Texto de cada página (`.txt`) y posición de sus líneas (`.geometry`)."""
    stem = REFERENCE / Path(source).stem
    current = {".txt": "\f".join(pages), ".geometry": "\n".join(geometry_of(pdf)) + "\n"}
    if update:
        REFERENCE.mkdir(exist_ok=True)
        for suffix, content in current.items():
            stem.with_suffix(suffix).write_text(content)
        return
    for suffix, content in current.items():
        reference = stem.with_suffix(suffix)
        if not reference.exists():
            fail(name, f"falta la referencia {reference.relative_to(ROOT)} (usa --update)")
            continue
        expected = reference.read_text()
        if expected == content:
            continue
        if suffix == ".txt":
            old, new = expected.split("\f"), content.split("\f")
            different = [n for n, (a, b) in enumerate(zip(old, new), 1) if a != b]
            if len(old) != len(new):
                fail(name, f"tiene {len(new)} páginas y la referencia {len(old)}")
            if different:
                fail(name, f"el texto difiere de la referencia en las páginas {different[:10]} (--update si es intencionado)")
        else:
            fail(name, "la posición de las líneas difiere de la referencia: márgenes o interlineado (--update si es intencionado)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-k", help="solo los archivos cuyo nombre contenga este texto")
    parser.add_argument("--update", action="store_true", help="regenera test/reference/")
    parser.add_argument("--no-reference", action="store_true", help="no compara con las referencias")
    args = parser.parse_args()

    for tool in ("typst", "pdftotext"):
        if shutil.which(tool) is None:
            print(f"Falta `{tool}` en el PATH", file=sys.stderr)
            return 2

    sources = sorted(ROOT.glob("test/*.typ")) + sorted(ROOT.glob("demos/*.typ"))
    sources = [s for s in sources if s.name not in SKIP and (not args.k or args.k in s.name)]
    out_dir = Path(tempfile.mkdtemp(prefix="documentclass-"))
    try:
        for source in sources:
            rel = source.relative_to(ROOT).as_posix()
            print(rel)
            pdf = out_dir / (source.stem + ".pdf")
            error = compile_pdf(source, pdf)
            if error:
                fail(rel, f"no compila: {error}")
                continue
            pages = pages_text(pdf)
            check_folio_only(rel, pages)
            check_folios(rel, pages)
            if rel not in NO_OVERLAP_CHECK:
                check_overlap(rel, pdf)
            if source.name == "structure_book.typ":
                check_structure_book(rel, pages)
            if source.name == "essay_default.typ":
                check_no_date(rel, pages)
            if source.name in ("verify_off.typ", "verify_on.typ"):
                check_verify(rel, pages, visible=source.name == "verify_on.typ")
            if rel in REFERENCED and not args.no_reference:
                check_reference(rel, rel, pages, pdf, args.update)
    finally:
        shutil.rmtree(out_dir, ignore_errors=True)

    print()
    if failures:
        print(f"{len(failures)} fallo(s):")
        for f in failures:
            print(f"  - {f}")
        return 1
    print(f"{len(sources)} archivos correctos")
    return 0


if __name__ == "__main__":
    sys.exit(main())
