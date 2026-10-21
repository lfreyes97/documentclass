
#import "../lib.typ": back, book, front, main

#show: book.with(
  title: "Test Book",
  author: "Tester",
  date: "2024",
  // Testing configurable fonts
  fonts: (
    heading: ("Roboto", "Arial"),
    toc: ("Roboto", "Arial"),
  ),
)

#show: front
= Front Matter
Some text.

#show: main
= Chapter 1
Some text.
== Section 1.1
Some text.
