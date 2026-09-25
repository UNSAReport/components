# @unsareport/standard-report-theming

Theme variables, typography, geometry, paragraph spacing, heading sizes, and table styling for UNSA standard reports.

## Overview

This package isolates all aesthetic and structural sizing tokens used by `@unsareport/standard-report`. It exposes pure `#let` bindings with zero logic or layout functions, making theme customization clean and modular.

## Included Tokens

- **Typography**: `font-family`, `font-size`, `font-lang`, `font-hyphenate`
- **Geometry**: `page-paper`, `cover-margin`, `body-margin`, `page-numbering`, `page-number-align`
- **Paragraph Spacing**: `par-justify`, `par-first-line-indent`, `par-spacing`, `par-leading`, `cover-par-leading`
- **Headings & Title**: `heading-font-size`, `heading-weight`, `heading-space-above`, `heading-space-below`, `title-text-size`, `title-weight`, `title-space-below`
- **Indentation Engine**: `indent-width`, `num-gutter`
- **Tables & Figures**: `table-header-fill`, `table-cell-stroke`, `table-text-size`, `table-header-weight`
- **Institutional Defaults**: `cover-logo-width`, `default-university`, `default-faculty`, `default-school`, `default-activity-type`, `default-city-country`

## Usage

Consumed directly by `@unsareport/standard-report`:

```typst
#import "/components/@unsareport/standard-report-theming/lib.typ": *
```
