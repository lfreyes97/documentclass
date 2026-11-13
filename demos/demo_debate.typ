// Fixture de la clase debate: fragmento del Período de preguntas del debate Bahnsen–Sproul
// (RTS, 1977), con interrupciones, un turno que continúa, preguntas del público y un orador sin
// nombre, reacciones del público y marcas de la transcripción (`crowd`, `inaudible`, `at`, `tnote`).
#import "../lib.typ": at, crowd, debate, inaudible, segment, tnote, turn

#show: debate.with(
  title: "El Debate sobre el Método Apologético",
  subtitle: "Reformed Theological Seminary",
  proposition: [Período de preguntas],
  venue: "Jackson, Mississippi",
  date: "1977",
  original: (
    title: "Bahnsen–Sproul Debate on Apologetic Method",
    series: "The Bahnsen-Sproul Debate Over Apologetic Method",
    recording: "1977",
    transcript: "Archivo Bahnsen",
  ),
  template: "two-speakers",
  marks: (timecodes: true),
  speakers: (
    bahnsen: (name: "Greg L. Bahnsen", short: "Bahnsen", role: "presuposicionalista"),
    sproul: (name: "R. C. Sproul", short: "Sproul", role: "clásico"),
    dewitt: (name: "Richard Dewitt", short: "Dewitt", role: "moderador", moderator: true),
  ),
)

#segment("questions", time: duration(minutes: 25))

#turn("dewitt")[
  Dr. Sproul, ¿le he oído decir que la apologética presuposicionalista representa un abandono a la
  metodología neo-ortodoxa?
]
#turn("sproul")[¿Un abandono?]
#turn("dewitt")[Bueno, una adopción de su metodología, es decir, un abandono de lo clásico reformado…]
#turn("sproul")[Puede que lo tengas grabado, pero yo quiero…]
#turn("dewitt")[Algo así, me gustaría que lo explicaras un poco, lo que quisiste decir con eso.]
#turn("sproul")[
  De acuerdo. Lo que originalmente había preparado para esta noche, pero el tiempo no me lo permitió,
  fue dar un breve recuento histórico del surgimiento del fideísmo#footnote[Postura que sostiene que el
  conocimiento de Dios se alcanza únicamente por la fe, sin apoyo de argumentos racionales.] como
  alternativa a la teología natural#tnote[En el original, *fideism*; no existe un término más común en español.].

  Tengo mucho miedo de la implicación más amplia de ese método.
]
#turn("dewitt")[¿Desea decir algo, profesor Bahnsen?]
#turn("bahnsen")[
  El conocimiento que todos los hombres tienen es una clara, perspicaz y cierta revelación de Dios que
  llega a todos a través de la naturaleza.
]
#turn("sproul")[¿Podría repetirlo al final? #inaudible No oí si dijiste «mediato» o «inmediato».]
#turn("bahnsen")[El conocimiento que todos los hombres tienen es inmediato.]
#turn("sproul")[¿Y no mediato?]
#turn("bahnsen")[Y no mediato.]
#turn("sproul")[¿Difiere usted de Calvino en ese momento?]
#turn("bahnsen")[
  No voy a debatir la exégesis histórica de Calvino, en realidad. No creo que discrepo con Calvino, pero
  esa es realmente una pregunta para el departamento de historia de la iglesia.
]
#turn("dewitt")[
  Oh, yo no lo habría hecho… Creo que ambos se equivocan con Calvino. Greg Fresnoll, levántese cuando haga
  sus preguntas y díganos su nombre. #crowd[risas]
]
#turn(none, label: "Miembro del público")[
  Mi nombre es Greg… RC, usted recuerda en Atlanta, haciendo una pregunta que tiene que ver con la lógica
  mediata e inmediata: si Satanás tentara a Eva y ella dijera «No, estoy engordando, será mejor que no
  lo coja», ¿habría pecado?
]
#turn("sproul")[
  Bueno, antes de que comiera la fruta prohibida y la caída, me imaginé que tenía la figura más fantástica
  del mundo y que no estaba ni un poquito preocupada por engordar. #crowd[risas] Greg, en realidad no estoy
  seguro de entender esa pregunta. ¿Entendiste la pregunta?
]
#turn("bahnsen")[#at("41:05") Sí.]
#turn("sproul")[¿Lo hiciste? ¿Podrías ayudarme un poco?]
#turn("sproul", cont: true)[Te daré algo a lo que disparar. Te daré una respuesta y luego…]
#turn("sproul")[Vamos a escucharlo primero, y luego tal vez eso aclare las preguntas en mi mente…]
#turn("bahnsen")[
  Según tengo entendido, Greg está preguntando sobre los fundamentos morales de la epistemología. Verás,
  Eva se enfrenta a una situación. Satanás dice: «Toma el fruto». Dios dice: «No tomes el fruto». Tiene
  que tomar una decisión. ¿Sobre qué base debe tomar la decisión?

  Es una cuestión de obediencia al Señorío de Dios solamente. Si de hecho no comía el fruto para salvar su
  figura, habría demostrado que estaba usando un criterio inmoral, porque la verdadera cuestión es si
  sería sumisa a los pensamientos de Dios, y no a los suyos propios.
]
#turn("sproul")[
  Eso realmente me ayuda a entender la pregunta, y ciertamente estaría de acuerdo con la conclusión que
  Greg acaba de dar.
]

#segment("rebuttal", speaker: "bahnsen")

#turn("dewitt")[Prof. Bahnsen, ¿cómo es eso un argumento?]
#turn("bahnsen")[¿El argumento trascendental?]
#turn("dewitt")[¿Cómo es que lo que has dicho ahora es un argumento?]
#turn("bahnsen")[Le daré un ejemplo de un argumento trascendental.]
#turn("dewitt")[
  ¿Puedo explicarme? Lo has descrito como una condición previa, una presuposición y un argumento. Puedo
  entender que es una presuposición y una condición previa. Pero me gustaría una pequeña aclaración sobre
  cómo es un argumento.
]
#turn("bahnsen")[
  Sí, por supuesto. Te daré una cosa más simple de seguir, mucho antes de Kant y algo con lo que ni RC ni
  yo discutiríamos, me imagino: Aristóteles.

  Aristóteles dice: «¿Cómo se prueba la ley de la no contradicción?» Puedes intentar argumentarlo por tus
  propios motivos, en cuyo caso es razonamiento circular; pero podemos argumentar a favor de la ley de la
  no contradicción desde la imposibilidad de lo contrario. Ese es exactamente el lenguaje de Van Til.
]
#turn("sproul")[
  En ese momento es un argumento de seres necesarios. Permítanme hacerle una pregunta que puede ayudar a
  todo el mundo: ¿estás diciendo, Greg, que lo que Van Til plantea es una reafirmación muy sofisticada del
  argumento ontológico?
]
#turn("bahnsen")[
  En mis clases de apologética tengo lo que se llama una reconstrucción del argumento ontológico…
]
#turn("dewitt")[¿Tiene alguna pregunta? Alguien atrás… Craig, sí.]
#turn(none, label: "Craig")[
  Me gustaría ir por un momento a la discusión ontológica: ¿hay algo en ese punto que por necesidad lo
  lleve a moverse a una revelación especial?
]
#turn("sproul")[
  Creo que esa es una excelente pregunta. En defensa de la fe cristiana, no estoy interesado en detenerme
  en este algo eterno y necesario sin más.
]
#turn("bahnsen")[Si sus premisas son ciertas, sí.]
#turn("sproul")[Si mis premisas son ciertas, entonces te he dado una conclusión cierta.]
#turn("bahnsen")[A menos que Dios le haya dicho antes que usted…]
#turn("sproul")[A menos que Dios me lo haya dicho. ¿Ok?]
