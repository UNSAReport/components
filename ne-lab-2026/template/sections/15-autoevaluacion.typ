= Autoevaluación

== Autoevaluación individual en el equipo

#lorem(30)

#figure(
  caption: [Autoevaluación cuantitativa del equipo de trabajo en escala 0 a 100.],
  table(
    columns: (1fr, 80pt),
    align: (left, center),
    stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { (bottom: 0.5pt + luma(200)) },
    table.header([Apellidos y Nombres de miembros del equipo], [Puntos]),
    [Integrante 1], [100],
    [Integrante 2], [100],
    [Integrante 3], [100],
    [Integrante 4], [100],
  ),
)
