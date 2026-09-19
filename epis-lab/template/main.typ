#import "/components/@unsareport/epis-lab/lib.typ": unsa-report, lab-section, code-block

#show: unsa-report.with(
  course_name: "Calidad de Software",
  lab_title: "Práctica 01",
  lab_number: "01",
  instructor_name: "Docente del Curso",
  members: (
    "Nombre del Estudiante",
  ),
  logo-epis: image("img/epis.png", width: 95%),
  logo-abet: image("img/abet.png", width: 97%),
  custom_variables: (
    course_abbr: "CAS",
    shortnames_chain: "ESTUDIANTE",
  ),
)

#include "sections/1-resultados.typ"
#v(0.5em)
#include "sections/2-conclusiones.typ"
