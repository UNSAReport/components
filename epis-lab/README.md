# @unsareport/epis-lab

UNSA EPIS laboratory report format: page header with institutional logos, basic-info table, themed sections, plus the post-build copy hook. Depends on `@unsareport/epis-lab-theming`, `@unsareport/define`, and `@unsareport/gdocs-code-block` (re-exported, so one import covers all).

## Template usage

```typst
#import "/components/@unsareport/epis-lab/lib.typ": unsa-report, lab-section, code-block

#show: unsa-report.with(
  course_name: "Calidad de Software",
  lab_title: "Práctica 01",
  lab_number: "01",
  instructor_name: "Docente del Curso",
  members: ("Nombre del Estudiante",),
  custom_variables: (
    course_abbr: "CAS",
    shortnames_chain: "ESTUDIANTE",
  ),
)

#lab-section("I. Resultados")[...]
```

`unsa-report` takes `course_name`, `lab_title`, `lab_number`, `instructor_name`, `members`, plus optional `year` / `presentation_date` / `sem_code` (default: today / today / A-B by month), `presentation_hour`, `logo-epis` / `logo-abet` overrides, and `custom_variables` (each `define()`d, so the hook can read them). Also exported: `page-header()`, `basic-info-table(...)`, `lab-section(title, ..bodies)`.

## copy-report hook

Copies `report.pdf` to the required `filename_format` after build. Requires Bun; reads vars via `@unsareport/define`'s `scripts/read-vars.ts`.

Install prompts for the required config (stored in `unsareport.d/config/unsareport-epis-lab.toml`, passed to the hook as `UNSAREP_CONFIG_EPIS_LAB_FILENAME_FORMAT`):

```toml
[config-schema.filename_format]  # required = true, no default
# e.g. "{shortnames_chain} - {course_abbr} - LAB {lab_number}.pdf"
```

Bind to `[hooks.build].after` (the script needs the just-compiled `report.pdf`; `before` has nothing to copy). Unknown `{token}` fails naming the token and the available vars.
