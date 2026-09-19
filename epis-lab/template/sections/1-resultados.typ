#import "/components/@unsareport/epis-lab/lib.typ": lab-section, code-block

#lab-section("I. RESULTADOS")[
  = Implementación y Verificación

  En esta sección se describen los resultados obtenidos durante la práctica de laboratorio.

  A continuación se muestra un ejemplo de bloque de código utilizando `@unsareport/gdocs-code-block`:

  #code-block(
    ```python
    def saludar(nombre: str) -> str:
        return f"Hola, {nombre}!"

    print(saludar("Mundo"))
    ```.text,
    lang: "python",
  )
]
