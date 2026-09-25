#import "/components/@unsareport/standard-report/lib.typ": standard-report, no-indent-block, force-indent-block

#show: standard-report.with(
  title: [TÍTULO DEL INFORME O ACTIVIDAD PRÁCTICA],
  authors: (
    "Integrante 1",
    "Integrante 2",
  ),
  authors_short: "Integrante1-Integrante2",
  course: "GESTIÓN DE PROYECTOS DE SOFTWARE",
  course_abbr: "GPS",
  group: "TURNO A - GRUPO 1",
  teacher: "MG. DOCENTE DEL CURSO",
  activity_type: "ACTIVIDAD PRÁCTICA",
  activity_number: "T1",
)

#include "sections/1-introduccion.typ"
#include "sections/2-desarrollo.typ"
#include "sections/3-conclusiones.typ"
