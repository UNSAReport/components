# @unsareport/define

Export named variables from a Typst document and read them back — inside Typst or from a hook script.

## Typst API (`lib.typ`)

```typst
#import "/components/@unsareport/define/lib.typ": define, get-var, get-all-vars

#define("course_abbr", "CAS")

#context [
  Abbr: #get-var("course_abbr") \
  Missing with fallback: #get-var("nope", default: "n/a")
]
```

- `define(name, value)` — exports `metadata((name: name, value: value))` under `<var_export>`.
- `get-var(name, default: none)` — value of one var; panics when missing and no default is given.
- `get-all-vars()` — all exported vars as a dictionary.

## Script API (`scripts/read-vars.ts`)

For Bun hook scripts that need the same vars outside Typst:

```ts
import { readVars } from "@unsareport/define/scripts/read-vars.ts";

const vars = await readVars(rootDir, entryFile);
// { course_abbr: "CAS", members: "Ana, Luis", ... }
```

Array values join with `", "`. The `<var_export>` wire shape is owned here — hook scripts must not re-implement the `typst eval` call. Fails fast when `typst` is missing, the evaluation fails, or output is not a JSON list.
