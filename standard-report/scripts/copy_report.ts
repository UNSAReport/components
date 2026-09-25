#!/usr/bin/env bun
/// Post-build hook for `@unsareport/standard-report`.
///
/// Copies the compiled report.pdf to the required `filename_format` derived
/// from metadata variables exported via `<var_export>` (read through
/// `@unsareport/define`'s shared reader).
///
/// Runs as an after-build hook: unsarep sets cwd to the project root and
/// exports UNSAREP_REPORT_DIR, UNSAREP_TYPST_ENTRY, and
/// UNSAREP_CONFIG_STANDARD_REPORT_FILENAME_FORMAT (installed from the package's
/// required `filename_format` config).

import { copyFileSync, existsSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { readVars } from "@unsareport/define/scripts/read-vars.ts";

const CONFIG_FILENAME = "unsareport.toml";
const DEFAULT_TYPST_ENTRY = "main.typ";
const COMPILED_PDF_NAME = "report.pdf";
const FORMAT_ENV = "UNSAREP_CONFIG_STANDARD_REPORT_FILENAME_FORMAT";

function formatFilename(
  pattern: string,
  metadata: Record<string, string>,
): string {
  const formatted = pattern.replace(
    /\{([a-zA-Z0-9_]+)\}/g,
    (_match, token: string) => {
      if (token in metadata) {
        return metadata[token];
      }
      throw new Error(
        `Required metadata variable '${token}' not found in document metadata. ` +
          `Available variables: ${JSON.stringify(Object.keys(metadata).sort())}`,
      );
    },
  );
  return formatted.endsWith(".pdf") ? formatted : `${formatted}.pdf`;
}

const rootDir = process.cwd();
if (!existsSync(join(rootDir, CONFIG_FILENAME))) {
  throw new Error(
    `Could not find '${CONFIG_FILENAME}' in current directory '${rootDir}' ` +
      "(unsarep build sets cwd to the project root)",
  );
}

const reportName = Bun.argv[2] ?? process.env.UNSAREP_REPORT_DIR;
if (!reportName) {
  throw new Error(
    "No report dir: run via 'unsarep docs build <report-dir>' or pass it as argv[1]",
  );
}
const reportDir = join(rootDir, reportName);
if (!existsSync(reportDir) || !statSync(reportDir).isDirectory()) {
  throw new Error(`Report dir does not exist: ${reportDir}`);
}

const entryName = process.env.UNSAREP_TYPST_ENTRY ?? DEFAULT_TYPST_ENTRY;
const entryFile = join(reportDir, entryName);
if (!existsSync(entryFile)) {
  throw new Error(`Typst entry file not found: '${entryFile}'`);
}

const sourcePdf = join(reportDir, COMPILED_PDF_NAME);
if (!existsSync(sourcePdf)) {
  throw new Error(`Compiled PDF not found: expected '${sourcePdf}'`);
}

const pattern = process.env[FORMAT_ENV];
if (!pattern) {
  throw new Error(
    `Missing required config: ${FORMAT_ENV} is unset (install @unsareport/standard-report with its required filename_format)`,
  );
}

const metadata = await readVars(rootDir, entryFile);
if (Object.keys(metadata).length === 0) {
  throw new Error(
    `No exported metadata variables (<var_export>) found in '${entryFile}'`,
  );
}

const targetPdf = join(reportDir, formatFilename(pattern, metadata));
copyFileSync(sourcePdf, targetPdf);
console.log(
  `[@unsareport/standard-report] Copied compiled report to: ${relative(rootDir, targetPdf)}`,
);
