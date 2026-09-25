#import "/components/@unsareport/define/lib.typ": define, get-var, get-all-vars

#let INDENT-OPEN-MARK = "__indent-open"
#let INDENT-CLOSE-MARK = "__indent-close"
#let NO-INDENT-OPEN-MARK = "__no-indent-open"
#let NO-INDENT-CLOSE-MARK = "__no-indent-close"
#let FORCE-INDENT-OPEN-MARK = "__force-indent-open"
#let FORCE-INDENT-CLOSE-MARK = "__force-indent-close"
#let FORCE-INDENT-DEFAULT-LEVEL = 1
#let num-gutter = 0.6em
#let indent-width = 12pt
#let heading-num-width = state("heading-num-width", 0pt)
#let in-table = state("in-table", false)

#let no-indent-block(body) = [#metadata(NO-INDENT-OPEN-MARK)#body#metadata(NO-INDENT-CLOSE-MARK)]
#let force-indent-block(body) = [#metadata(FORCE-INDENT-OPEN-MARK)#body#metadata(FORCE-INDENT-CLOSE-MARK)]

#let auto-indent(it) = context {
  let marks = query(selector(metadata).before(here(), inclusive: false))
  let nest-depth = marks.filter(m => m.value == INDENT-OPEN-MARK).len() - marks.filter(m => m.value == INDENT-CLOSE-MARK).len()
  let plain-depth = marks.filter(m => m.value == NO-INDENT-OPEN-MARK).len() - marks.filter(m => m.value == NO-INDENT-CLOSE-MARK).len()
  let force-depth = marks.filter(m => m.value == FORCE-INDENT-OPEN-MARK).len() - marks.filter(m => m.value == FORCE-INDENT-CLOSE-MARK).len()
  let h = query(selector(heading).before(here())).at(-1, default: none)
  if force-depth > 0 {
    if h == none {
      block(inset: (left: indent-width * FORCE-INDENT-DEFAULT-LEVEL))[
        #it
      ]
    } else {
      let current-num-width = heading-num-width.get()
      block(inset: (left: indent-width * h.level + current-num-width))[
        #it
      ]
    }
  } else if plain-depth > 0 {
    it
  } else if in-table.get() {
    it
  } else if nest-depth > 0 {
    it
  } else if h == none {
    it
  } else {
    let current-num-width = heading-num-width.get()
    block(inset: (left: indent-width * h.level + current-num-width))[
      #it
    ]
  }
}

#let default-logo = image("img/unsa-escudo.png", height: 130pt)

#let ne-report(
  university: "UNIVERSIDAD NACIONAL DE SAN AGUSTIN DE AREQUIPA",
  faculty: "FACULTAD DE INGENIERIA DE PRODUCCION Y SERVICIOS",
  school: "ESCUELA PROFESIONAL DE INGENIERIA DE SISTEMAS",
  course: "NEGOCIOS ELECTRÓNICOS",
  docente: "Dr. Ing. César Baluarte Araya",
  title: "Informe de Entregable e Informe de Investigación Formativa",
  session: "Sesión: Negocios Electrónicos",
  topic: none,
  group: "A",
  subgroup: "01",
  session_number: "01",
  deliverable_number: "1",
  year: none,
  semester: none,
  delivery_type: "INF",
  stage: none,
  authors: (),
  authors_short: none,
  date: none,
  city: "Arequipa - Perú",
  logo: auto,
  custom_variables: (:),
  body,
) = {
  let gen-time = datetime.today()
  let resolved-year = if year != none { str(year) } else { str(gen-time.year()) }
  let resolved-semester = if semester != none { semester } else { if gen-time.month() < 8 { "A" } else { "B" } }
  let resolved-date = if date != none {
    date
  } else {
    let months = ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "setiembre", "octubre", "noviembre", "diciembre")
    resolved-year + " " + months.at(gen-time.month() - 1)
  }

  let resolved-topic = if topic != none {
    topic
  } else if session.contains(" - ") {
    session.split(" - ").slice(1).join(" - ")
  } else {
    session
  }

  let resolved-authors-short = if authors_short != none {
    authors_short
  } else if authors.len() > 0 {
    authors.map(a => a.split(" ").at(0)).join("-")
  } else {
    "Grupo"
  }

  // Export metadata for unsarep and post-build copy hooks
  define("university", university)
  define("faculty", faculty)
  define("school", school)
  define("course", course)
  define("docente", docente)
  define("title", title)
  define("session", session)
  define("topic", resolved-topic)
  define("group", group)
  define("subgroup", subgroup)
  define("session_number", session_number)
  define("deliverable_number", deliverable_number)
  define("year", resolved-year)
  define("semester", resolved-semester)
  define("delivery_type", delivery_type)
  if stage != none { define("stage", stage) }
  define("authors", authors)
  define("authors_short", resolved-authors-short)
  define("date", resolved-date)
  define("city", city)

  for (name, val) in custom_variables {
    define(name, val)
  }

  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  )
  set text(
    font: ("Times New Roman", "Liberation Serif"),
    size: 12pt,
    lang: "es",
  )
  set par(
    leading: 0.65em,
    justify: true,
  )
  set heading(numbering: (..nums) => {
    let vals = nums.pos()
    if vals.len() == 1 {
      numbering("1.", vals.last())
    } else {
      numbering("a.", vals.last())
    }
  })
  show heading: set text(size: 12pt)
  show figure.where(kind: table): set block(breakable: true)
  set table.cell(breakable: false)

  show heading: it => {
    let num-content = if it.numbering != none {
      counter(heading).display(it.numbering)
    } else {
      none
    }
    let current-num-width = if num-content != none {
      measure(num-content).width + num-gutter
    } else {
      0pt
    }
    heading-num-width.update(current-num-width)
    block(inset: (left: indent-width * it.level))[
      #grid(
        columns: (current-num-width, 1fr),
        num-content,
        it.body
      )
    ]
  }

  show list.item: it => {
    let kids = it.body.at("children", default: none)
    if kids != none and kids.len() > 0 and kids.at(0).func() == metadata and kids.at(0).at("value", default: "") == INDENT-OPEN-MARK { it } else { list.item[#metadata(INDENT-OPEN-MARK)#it.body#metadata(INDENT-CLOSE-MARK)] }
  }
  show enum.item: it => {
    let kids = it.body.at("children", default: none)
    if kids != none and kids.len() > 0 and kids.at(0).func() == metadata and kids.at(0).at("value", default: "") == INDENT-OPEN-MARK { it } else { enum.item[#metadata(INDENT-OPEN-MARK)#it.body#metadata(INDENT-CLOSE-MARK)] }
  }

  show par: auto-indent
  show enum: auto-indent
  show list: auto-indent
  show bibliography: auto-indent
  show figure: auto-indent
  show raw.where(block: true): auto-indent

  set table(
    inset: (x: 8pt, y: 6pt),
    fill: (x, y) => if y == 0 { rgb("#edf2f7") } else { none },
  )
  show table.cell.where(y: 0): set text(weight: "bold")
  show table: it => {
    in-table.update(true)
    it
    in-table.update(false)
  }

  block(
    width: 100%,
    height: 100%,
  )[
    #align(center)[
      #set par(leading: 1.5em)
      #text(
        size: 16pt,
        weight: "bold",
      )[#university] \
      #text(
        size: 14pt,
        weight: "bold",
      )[#faculty] \
      #text(
        size: 14pt,
        weight: "bold",
      )[#school]
    ]

    #v(16pt)
    #let resolved-logo = if logo == auto {
      default-logo
    } else {
      logo
    }
    #if resolved-logo != none {
      align(center)[#resolved-logo]
      v(24pt)
    }

    #text(size: 16pt)[
      #grid(
        columns: (105pt, 1fr),
        row-gutter: 30pt,
        [Curso:], [#course],
        [Docente:], [#docente],
      )
    ]

    #v(16pt)
    #align(center)[
      #set par(leading: 1.2em)
      #text(
        size: 15pt,
        weight: "bold",
      )[#title] \
      #text(
        size: 15pt,
        weight: "bold",
      )[#session]
    ]

    #v(24pt)
    #text(size: 14pt)[
      #grid(
        columns: (130pt, 1fr),
        row-gutter: 8pt,
        ..authors.enumerate().map(e => (
          if e.at(0) == 0 { [Elaborado por:] } else { [] },
          [#e.at(1)],
        )).flatten(),
      )
    ]

    #v(18pt)
    #text(size: 14pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 25pt,
        [
          #set par(spacing: 0.75em)
          Observaciones.- #box(width: 1fr)[#repeat[-]]
          #repeat[-]
          #repeat[-]
          #repeat[-]
        ],
        align(top + right)[
          Nota: #box(width: 75pt, baseline: -1pt)[#line(length: 100%, stroke: 0.8pt)]
        ],
      )
    ]

    #v(1fr)
    #align(center)[
      #text(size: 14pt)[
        #resolved-date \
        #v(3pt)
        #city
      ]
    ]
  ]

  pagebreak()

  [Índice General]

  outline(
    title: none,
    indent: auto,
  )

  pagebreak()

  body
}
