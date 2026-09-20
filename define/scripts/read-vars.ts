/// Shared var reader for `@unsareport/define`.
///
/// Runs `typst query` over a report entry file and returns the exported
/// `<var_export>` vars as a string dict (array values joined with `", "`).
/// The wire shape (`<var_export>` items shaped by `define()`'s
/// `metadata((name, value))` payload) is owned here so hook scripts never
/// re-implement the query.

export const METADATA_LABEL = "<var_export>";

type QueryItem = {
  name?: unknown;
  value?: unknown;
};

export async function readVars(
  rootDir: string,
  entryFile: string,
): Promise<Record<string, string>> {
  if (Bun.which("typst") === null) {
    throw new Error("Could not find 'typst' executable on PATH");
  }
  const proc = Bun.spawn(
    [
      "typst",
      "query",
      entryFile,
      METADATA_LABEL,
      "--field",
      "value",
      "--root",
      rootDir,
    ],
    { cwd: rootDir, stdout: "pipe", stderr: "pipe" },
  );
  const [stdout, stderr, code] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  if (code !== 0) {
    throw new Error(`Typst query failed (code ${code}): ${stderr.trim()}`);
  }
  const text = stdout.trim();
  if (text === "") {
    return {};
  }
  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch (err) {
    throw new Error(
      `Failed to parse JSON from typst query: ${err}\nOutput: ${text}`,
    );
  }
  if (!Array.isArray(data)) {
    throw new Error(`Unexpected query output format: ${typeof data}`);
  }
  const metadata: Record<string, string> = {};
  for (const item of data as QueryItem[]) {
    if (item?.name == null || item?.value == null) {
      continue;
    }
    const value = item.value;
    metadata[String(item.name)] = Array.isArray(value)
      ? value.map((v) => String(v)).join(", ")
      : String(value);
  }
  return metadata;
}
