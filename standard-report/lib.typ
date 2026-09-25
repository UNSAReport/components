#import "/components/@unsareport/standard-report-theming/lib.typ": *
#import "/components/@unsareport/define/lib.typ": define, get-var, get-all-vars

#let INDENT-OPEN-MARK = "__indent-open"
#let INDENT-CLOSE-MARK = "__indent-close"
#let NO-INDENT-OPEN-MARK = "__no-indent-open"
#let NO-INDENT-CLOSE-MARK = "__no-indent-close"
#let FORCE-INDENT-OPEN-MARK = "__force-indent-open"
#let FORCE-INDENT-CLOSE-MARK = "__force-indent-close"
#let FORCE-INDENT-DEFAULT-LEVEL = 1

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
      block(inset: (left: indent-width * FORCE-INDENT-DEFAULT-LEVEL))[#it]
    } else {
      let current-num-width = heading-num-width.get()
      block(inset: (left: indent-width * h.level + current-num-width))[#it]
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
    block(inset: (left: indent-width * h.level + current-num-width))[#it]
  }
}

#let default-logo = image("img/logo.png", width: cover-logo-width)

#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) == content {
    let f = it.fields()
    if "text" in f {
      f.text
    } else if "children" in f {
      f.children.map(to-string).join("")
    } else if "body" in f {
      to-string(f.body)
    } else if it.func() == [ ].func() {
      " "
    } else {
      ""
    }
  } else {
    ""
  }
}

#let standard-report(
  title: "",
  authors: (),
  course: "",
  teacher: none,
  docente: none,
  group: "",
  activity_type: default-activity-type,
  activity_number: "T1",
  course_abbr: none,
  authors_short: none,
  year: none,
  university: default-university,
  faculty: default-faculty,
  school: default-school,
  city_country: default-city-country,
  logo: auto,
  custom_variables: (:),
  doc,
) = {
  let gen-time = datetime.today()
  let resolved-year = if year != none { str(year) } else { str(gen-time.year()) }
  let resolved-teacher = if teacher != none {
    teacher
  } else if docente != none {
    docente
  } else {
    ""
  }

  let resolved-course-abbr = if course_abbr != none {
    course_abbr
  } else {
    ""
  }

  let resolved-authors-short = if authors_short != none {
    authors_short
  } else if group != "" {
    group
  } else if authors.len() > 0 {
    authors.map(a => a.split(" ").at(0)).join("-")
  } else {
    "Informe"
  }

  let resolved-title-str = to-string(title)

  // Export metadata variables for unsarep and post-build copy hooks
  define("title", resolved-title-str)
  define("course", course)
  define("course_abbr", resolved-course-abbr)
  define("teacher", resolved-teacher)
  define("docente", resolved-teacher)
  define("group", group)
  define("activity_type", activity_type)
  define("activity_number", activity_number)
  define("authors", authors)
  define("authors_short", resolved-authors-short)
  define("year", resolved-year)
  define("university", university)
  define("faculty", faculty)
  define("school", school)
  define("city_country", city_country)

  for (name, val) in custom_variables {
    define(name, val)
  }

  // Typography and base formatting
  set text(
    font: font-family,
    size: font-size,
    hyphenate: font-hyphenate,
    lang: font-lang,
  )

  set page(margin: cover-margin)

  set par(
    justify: par-justify,
    first-line-indent: par-first-line-indent,
    spacing: par-spacing,
    leading: par-leading,
  )

  set heading(numbering: (..nums) => {
    let vals = nums.pos()
    let pattern = range(vals.len()).map(_ => "1").join(".") + "."
    numbering(pattern, ..vals)
  })
  show heading: set text(size: heading-font-size, weight: heading-weight)
  show heading: set block(above: heading-space-above, below: heading-space-below)

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
        it.body,
      )
    ]
  }

  show figure.where(kind: table): set block(breakable: true)
  set table.cell(breakable: false)

  show list.item: it => {
    let kids = it.body.at("children", default: none)
    if kids != none and kids.len() > 0 and kids.at(0).func() == metadata and kids.at(0).at("value", default: "") == INDENT-OPEN-MARK {
      it
    } else {
      list.item[#metadata(INDENT-OPEN-MARK)#it.body#metadata(INDENT-CLOSE-MARK)]
    }
  }
  show enum.item: it => {
    let kids = it.body.at("children", default: none)
    if kids != none and kids.len() > 0 and kids.at(0).func() == metadata and kids.at(0).at("value", default: "") == INDENT-OPEN-MARK {
      it
    } else {
      enum.item[#metadata(INDENT-OPEN-MARK)#it.body#metadata(INDENT-CLOSE-MARK)]
    }
  }

  show par: auto-indent
  show enum: auto-indent
  show list: auto-indent
  show bibliography: auto-indent
  show figure: auto-indent
  show raw.where(block: true): auto-indent

  show figure.where(kind: table): set text(size: table-text-size)
  show table.cell.where(y: 0): set text(weight: table-header-weight)
  set table(
    fill: (col, row) => if row == 0 { table-header-fill } else { none },
    stroke: (x, y) => table-cell-stroke,
  )
  show table: it => {
    in-table.update(true)
    it
    in-table.update(false)
  }

  show figure.caption: it => [
    #it.supplement #context it.counter.display(it.numbering). #it.body
  ]

  // Cover Page
  let resolved-logo = if logo == auto {
    default-logo
  } else {
    logo
  }

  align(center)[
    #set par(leading: cover-par-leading)
    #strong[#university]\
    #strong[#faculty]\
    #strong[#school]\ \

    #if resolved-logo != none {
      resolved-logo
      [\ ]
    }

    #strong[#activity_type]\
    #title\ \

    #strong[ASIGNATURA]\
    #course\
    #if group != "" [#group\ ]\

    #strong[DOCENTE]\
    #resolved-teacher\ \

    #strong[INTEGRANTES]\
    #if type(authors) == array {
      authors.join("\n")
    } else {
      authors
    }\
    \

    #strong[#city_country]\
    #strong[#resolved-year]
  ]

  pagebreak()

  // Body Pages
  set page(
    numbering: page-numbering,
    number-align: page-number-align,
    margin: body-margin,
  )
  counter(page).update(1)

  set par(
    justify: par-justify,
    leading: par-leading,
    spacing: par-spacing,
    first-line-indent: par-first-line-indent,
  )

  align(center)[
    #set text(size: title-text-size, weight: title-weight)
    #block(below: title-space-below)[#title]
  ]

  doc
}

#let project = standard-report
