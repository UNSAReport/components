# @unsareport/epis-lab-theming

Theme variables for EPIS lab reports: brand colors, typography, page geometry, and section/table sizing. No functions — just `let` bindings consumed by `@unsareport/epis-lab`.

## Usage

```typst
#import "/components/@unsareport/epis-lab-theming/lib.typ": *
// primary-color, font-family, page-margin, section-header-fill, ...

#table(fill: info-header-fill)[...]
```

Override by defining the same name after the import in your own file. Key groups: colors (`primary-color`, `header-border-color`, `code-bg-color`), typography/geometry (`font-family`, `font-lang`, `page-paper`, `page-margin`), header (`header-*-text-size`), info table (`info-*`), headings/lists (`heading-1-size`, `list-marker`, `enum-numbering`), lab sections (`section-*`).
