# @unsareport/ne-lab-2026

Formato oficial para Informes de Entregable e Informes de Investigación Formativa del curso de **Negocios Electrónicos** (UNSA - EPIS): portada institucional con escudo oficial, sistema de indentación y sangría jerárquica reactiva por niveles de encabezado, índice general automático y hook post-build de renombrado formal.

Depende de `@unsareport/define` (re-exportado directamente, permitiendo definir y consultar variables de metadatos del documento).

## Uso de la plantilla

```typst
#import "/components/@unsareport/ne-lab-2026/lib.typ": ne-report, no-indent-block, force-indent-block

#show: ne-report.with(
  group: "A",
  subgroup: "01",
  session_number: "01",
  deliverable_number: "1",
  session: "Sesión: Negocios Electrónicos - Tiendas Virtuales",
  topic: "Tiendas Virtuales",
  authors: (
    "Integrante 1",
    "Integrante 2",
    "Integrante 3",
    "Integrante 4",
  ),
  authors_short: "Integrante1-Integrante2-Integrante3-Integrante4",
  date: "2026 setiembre",
)

#include "sections/1-planificar.typ"
// ... secciones 2 a 15 incluidas en el template
```

La plantilla incluye la estructura completa modular de las 15 secciones requeridas por el curso y el checklist oficial de validación en `template/checklist.md`.

`ne-report` acepta los parámetros:
- `university`, `faculty`, `school` (valores por defecto institucionales UNSA / FIPS / EPIS).
- `course` (por defecto: `"NEGOCIOS ELECTRÓNICOS"`).
- `docente` (por defecto: `"Dr. Ing. César Baluarte Araya"`).
- `title` (por defecto: `"Informe de Entregable e Informe de Investigación Formativa"`).
- `session` (e.g. `"Sesión: Negocios Electrónicos - Tiendas Virtuales"`).
- `topic` (opcional, extraído de `session` si se omite).
- `group`, `subgroup`, `session_number`, `deliverable_number` (identificadores para la entrega).
- `year`, `semester` (por defecto calculados con la fecha actual, e.g. `2026`, `B`).
- `delivery_type` (por defecto: `"INF"`).
- `stage` (opcional, e.g. `"Final"`, `"Previo"`).
- `authors` (lista de integrantes).
- `authors_short` (opcional; si se omite, se deduce automáticamente uniendo el primer apellido de cada autor).
- `date`, `city` (por defecto mes/año actual y `"Arequipa - Perú"`).
- `logo` (por defecto: Escudo oficial UNSA).
- `custom_variables` (diccionario de pares clave-valor exportados vía `define()` para lectura en hooks o consultas Typst).

También se exportan los bloques de control de sangría: `no-indent-block(body)` y `force-indent-block(body)`, así como las funciones de `@unsareport/define`: `define`, `get-var` y `get-all-vars`.

## Hook copy-report

Copia `report.pdf` a la nomenclatura formal requerida por el curso tras la compilación exitosa. Requiere Bun y utiliza el lector compartido `readVars` de `@unsareport/define`.

La configuración solicitada durante la instalación se guarda en `unsareport.d/config/unsareport-ne-lab-2026.toml` y se transmite al hook como `UNSAREP_CONFIG_NE_LAB_2026_FILENAME_FORMAT`:

```toml
[config-schema.filename_format]
# Valor por defecto:
# "NE Grupo {group} Subgrupo {subgroup} - Sesión {session_number} {deliverable_number} - Inv For {year} {semester} INF - Informe Entregable e Informe Investigación Formativa - {topic} - {authors_short}.pdf"
```

El hook está configurado para ejecutarse en `[hooks.build].after`.
