# @unsareport/standard-report

UNSA standard report template and layout: institutional cover page, contextual hierarchical indentation engine, metadata export via `@unsareport/define`, and post-build automated renaming hook.

## Architecture

This package depends on:
- `@unsareport/standard-report-theming`: provides pure style tokens (typography, margins, heading sizes, table strokes/fills).
- `@unsareport/define`: provides document variable export (`define`) and context querying (`get-var`, `get-all-vars`).

## Features

- **Institutional Cover Page**: Centered official UNSA header (Universidad, Facultad, Escuela), escudo institucional (`img/logo.png`), activity label, title, course, group, teacher, authors list, city, and year.
- **Hierarchical Auto-Indentation Engine**: Paragraphs, lists, enums, tables, and figures automatically indent aligned to the active heading level and dynamically measured numbering width.
- **Nested List & Table Protection**: Avoids redundant double indentation on nested list items and preserves native layout within tables.
- **Escape Hatches**: Includes `no-indent-block(body)` and `force-indent-block(body)` for full-width elements.
- **Automated Post-Build Renaming Hook**: Integrates `commands.copy-report` with `hooks.build` to rename `report.pdf` using the format configured in `unsareport.d/config/unsareport-standard-report.toml`.

## Usage

```typst
#import "/components/@unsareport/standard-report/lib.typ": standard-report, no-indent-block, force-indent-block

#show: standard-report.with(
  title: [DOCUMENTACIÓN TÉCNICA DEL PROYECTO],
  authors: (
    "Integrante 1",
    "Integrante 2",
    "Integrante 3",
    "Integrante 4",
  ),
  authors_short: "Integrante1-Integrante2-Integrante3-Integrante4",
  course: "GESTIÓN DE PROYECTOS DE SOFTWARE",
  course_abbr: "GPS",
  group: "TURNO A - GRUPO 1",
  teacher: "MG. DOCENTE DEL CURSO",
  activity_type: "ACTIVIDAD PRÁCTICA",
  activity_number: "T2",
)

= Introducción

Contenido del informe...
```

## Post-Build Renaming Configuration

Configure the renaming pattern in `unsareport.toml` or `unsareport.d/config/unsareport-standard-report.toml`:

```toml
[config-schema.filename_format]
default = "{course_abbr} - {activity_number} - {group} - Informe.pdf"
```

Available tokens: `{course_abbr}`, `{course}`, `{activity_number}`, `{activity_type}`, `{group}`, `{authors_short}`, `{year}`, `{title}`, `{teacher}`, `{docente}`, `{university}`, `{faculty}`, `{school}`.
