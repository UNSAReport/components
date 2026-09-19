#!/usr/bin/env python3
"""Post-build hook for @unsareport/epis-lab.

Copies the compiled report.pdf to a user-configured formatted filename
derived from metadata variables exported via <var_export>.
"""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tomllib

METADATA_LABEL = "<var_export>"
CONFIG_FILENAME = "unsareport.toml"
DEFAULT_TYPST_ENTRY = "main.typ"
FALLBACK_TYPST_ENTRY = "report.typ"
COMPILED_PDF_NAME = "report.pdf"

DEFAULT_FORMAT_WITH_SHORTNAMES = (
    "{shortnames_chain} - {course_abbr} - LAB {lab_number}.pdf"
)
DEFAULT_FORMAT_STANDARD = "{course_name} - LAB {lab_number}.pdf"


def find_project_root(start_dir: Path) -> Path:
    """Traverse upwards from start_dir to find the directory containing unsareport.toml."""
    current = start_dir.resolve()
    while True:
        if (current / CONFIG_FILENAME).is_file():
            return current
        parent = current.parent
        if parent == current:
            raise FileNotFoundError(
                f"Could not find '{CONFIG_FILENAME}' walking up from '{start_dir}'"
            )
        current = parent


def load_project_config(root_dir: Path) -> dict:
    """Load unsareport.toml configuration."""
    config_file = root_dir / CONFIG_FILENAME
    if not config_file.is_file():
        raise FileNotFoundError(f"Missing config file: {config_file}")
    with config_file.open("rb") as f:
        return tomllib.load(f)


def resolve_report_dir(root_dir: Path, explicit_arg: str | None) -> Path:
    """Resolve the active report directory."""
    if explicit_arg:
        candidate = (root_dir / explicit_arg).resolve()
        if candidate.is_dir():
            return candidate
        raise NotADirectoryError(f"Specified report dir does not exist: {candidate}")

    env_dir = os.environ.get("UNSAREPORT_REPORT_DIR")
    if env_dir:
        candidate = (root_dir / env_dir).resolve()
        if candidate.is_dir():
            return candidate
        raise NotADirectoryError(f"UNSAREPORT_REPORT_DIR does not exist: {candidate}")

    # Search for directories containing COMPILED_PDF_NAME, picking the most recently modified
    matching_dirs = []
    for path in root_dir.glob(f"**/{COMPILED_PDF_NAME}"):
        # Ignore components and hidden directories
        rel_parts = path.relative_to(root_dir).parts
        if "components" in rel_parts or any(p.startswith(".") for p in rel_parts):
            continue
        matching_dirs.append((path.stat().st_mtime, path.parent))

    if not matching_dirs:
        # If no report.pdf found yet, check for directories with typst entry files
        for entry_name in (DEFAULT_TYPST_ENTRY, FALLBACK_TYPST_ENTRY):
            for path in root_dir.glob(f"**/{entry_name}"):
                rel_parts = path.relative_to(root_dir).parts
                if "components" in rel_parts or any(
                    p.startswith(".") for p in rel_parts
                ):
                    continue
                return path.parent
        raise FileNotFoundError(
            f"No active report directory containing '{COMPILED_PDF_NAME}' found under '{root_dir}'"
        )

    matching_dirs.sort(key=lambda item: item[0], reverse=True)
    return matching_dirs[0][1]


def resolve_typst_entry(report_dir: Path, config: dict) -> Path:
    """Determine the typst entry file."""
    configured_entry = config.get("project", {}).get("typst_entry")
    if configured_entry:
        candidate = report_dir / configured_entry
        if candidate.is_file():
            return candidate

    for name in (DEFAULT_TYPST_ENTRY, FALLBACK_TYPST_ENTRY):
        candidate = report_dir / name
        if candidate.is_file():
            return candidate

    typ_files = list(report_dir.glob("*.typ"))
    if len(typ_files) == 1:
        return typ_files[0]
    elif len(typ_files) > 1:
        raise RuntimeError(
            f"Multiple .typ files found in '{report_dir}', set [project] typst_entry in {CONFIG_FILENAME}"
        )
    else:
        raise FileNotFoundError(f"No .typ entry file found in '{report_dir}'")


def run_typst_query(root_dir: Path, entry_file: Path) -> list[dict]:
    """Execute typst query on entry_file to extract metadata."""
    typst_cmd = shutil.which("typst")
    if typst_cmd:
        cmd = [
            typst_cmd,
            "query",
            str(entry_file),
            METADATA_LABEL,
            "--field",
            "value",
            "--root",
            str(root_dir),
        ]
    else:
        nix_cmd = shutil.which("nix")
        if nix_cmd:
            cmd = [
                nix_cmd,
                "run",
                "nixpkgs#typst",
                "--",
                "query",
                str(entry_file),
                METADATA_LABEL,
                "--field",
                "value",
                "--root",
                str(root_dir),
            ]
        else:
            raise RuntimeError("Neither 'typst' nor 'nix' executable found on PATH")

    result = subprocess.run(
        cmd,
        cwd=root_dir,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"Typst query failed (code {result.returncode}): {result.stderr.strip()}"
        )

    output = result.stdout.strip()
    if not output:
        return []

    try:
        data = json.loads(output)
        if isinstance(data, list):
            return data
        raise ValueError(f"Unexpected query output format: {type(data)}")
    except json.JSONDecodeError as err:
        raise RuntimeError(
            f"Failed to parse JSON from typst query: {err}\nOutput: {output}"
        ) from err


def extract_metadata_dict(query_items: list[dict]) -> dict[str, str]:
    """Convert query items into a dictionary of string values."""
    metadata = {}
    for item in query_items:
        name = item.get("name")
        value = item.get("value")
        if name is not None and value is not None:
            if isinstance(value, list):
                metadata[name] = ", ".join(str(v) for v in value)
            else:
                metadata[name] = str(value)
    return metadata


def determine_format_pattern(config: dict, metadata: dict[str, str]) -> str:
    """Determine the filename pattern to use."""
    # Check config for configured format
    configured_format = (
        config.get("config", {})
        .get("epis-lab", {})
        .get(
            "filename_format",
            config.get("package", {})
            .get("epis-lab", {})
            .get("filename_format"),
        )
    )
    if configured_format:
        return configured_format

    # Choose default based on presence of shortnames_chain and course_abbr
    if "shortnames_chain" in metadata and "course_abbr" in metadata:
        return DEFAULT_FORMAT_WITH_SHORTNAMES
    return DEFAULT_FORMAT_STANDARD


def format_filename(pattern: str, metadata: dict[str, str]) -> str:
    """Replace {token} occurrences in pattern with metadata values."""

    def replace_token(match: re.Match) -> str:
        token = match.group(1)
        if token in metadata:
            return metadata[token]
        raise KeyError(
            f"Required metadata variable '{token}' not found in document metadata. "
            f"Available variables: {sorted(metadata.keys())}"
        )

    formatted = re.sub(r"\{([a-zA-Z0-9_]+)\}", replace_token, pattern)
    if not formatted.endswith(".pdf"):
        formatted += ".pdf"
    return formatted


def main() -> int:
    explicit_arg = sys.argv[1] if len(sys.argv) > 1 else None
    root_dir = find_project_root(Path.cwd())
    config = load_project_config(root_dir)
    report_dir = resolve_report_dir(root_dir, explicit_arg)
    entry_file = resolve_typst_entry(report_dir, config)

    source_pdf = report_dir / COMPILED_PDF_NAME
    if not source_pdf.is_file():
        # Check if PDF matches entry file basename
        alt_pdf = report_dir / f"{entry_file.stem}.pdf"
        if alt_pdf.is_file():
            source_pdf = alt_pdf
        else:
            raise FileNotFoundError(
                f"Compiled PDF not found: expected '{source_pdf}' or '{alt_pdf}'"
            )

    query_items = run_typst_query(root_dir, entry_file)
    metadata = extract_metadata_dict(query_items)

    if not metadata:
        raise RuntimeError(
            f"No exported metadata variables (<var_export>) found in '{entry_file}'"
        )

    pattern = determine_format_pattern(config, metadata)
    target_filename = format_filename(pattern, metadata)
    target_pdf = report_dir / target_filename

    shutil.copy2(source_pdf, target_pdf)
    rel_target = target_pdf.relative_to(root_dir)
    print(f"[@unsareport/epis-lab] Copied compiled report to: {rel_target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
