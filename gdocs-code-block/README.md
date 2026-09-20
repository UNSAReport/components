# @unsareport/gdocs-code-block

Google-Docs-styled code block with named snippet extraction.

## Usage

```typst
#import "/components/@unsareport/gdocs-code-block/lib.typ": code-block, extract-named-snippet

#code-block("print('hola')", lang: "python")

#code-block(
  read("main.py"),
  snippet: "demo",
  lang: "python",
)
```

`code-block(source, snippet: none, prefix: "//", lang: "text", fill: ..., breakable: true, width: 100%, inset: 1em, radius: 8pt, spacing: 0.65em, clip: false, text-size: 7pt)` renders `source` verbatim, or one named snippet of it. Snippets are delimited in the source file:

```python
# // START-SNIPPET,demo
print('only this is shown')
# // END-SNIPPET
```

`extract-named-snippet(source, snippet-name, prefix: "//")` returns the raw snippet string (panics when the snippet is missing or unclosed). `prefix` adapts the markers to other comment styles (e.g. `prefix: "#"`, `prefix: "%"`).
