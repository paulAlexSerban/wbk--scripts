#!/usr/bin/env python3
"""
bundle.py — Collect matching source files into a single Markdown file.

Usage:
    python bundle.py [OPTIONS]

Options:
    -r, --root       DIR     Root directory to scan (default: current dir)
    -p, --patterns   GLOBS   Pipe-separated glob patterns  (default: *.js|*.jsx)
    -e, --exclude    DIRS    Pipe-separated dirs to skip    (default: node_modules|.git|dist)
    -o, --output     FILE    Output markdown file           (default: bundle.md)
    --max-bytes      N       Skip files larger than N bytes (default: 500000)

Examples:
    python bundle.py -p "*.py" -e "__pycache__|.venv" -o snapshot.md
    python bundle.py -r ./src -p "*.ts|*.tsx" -o review.md
"""

import argparse
import fnmatch
import os
import sys
from pathlib import Path

# Language hint map: extension → markdown fence language tag
EXT_LANG = {
    ".js": "js", ".jsx": "jsx", ".ts": "ts", ".tsx": "tsx",
    ".py": "python", ".rb": "ruby", ".go": "go", ".rs": "rust",
    ".java": "java", ".kt": "kotlin", ".cs": "csharp", ".cpp": "cpp",
    ".c": "c", ".h": "c", ".swift": "swift", ".sh": "bash",
    ".html": "html", ".css": "css", ".scss": "scss", ".json": "json",
    ".yaml": "yaml", ".yml": "yaml", ".toml": "toml", ".md": "markdown",
    ".sql": "sql", ".php": "php", ".vue": "vue", ".svelte": "svelte",
    ".bash": "bash", ".sh": "sh"
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Bundle source files into a single Markdown file.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("-r", "--root", default=".", metavar="DIR",
                        help="Root directory to scan (default: .)")
    parser.add_argument("-p", "--patterns", default="*.js|*.jsx", metavar="GLOBS",
                        help='Pipe-separated glob patterns (default: "*.js|*.jsx")')
    parser.add_argument("-e", "--exclude", default="node_modules|.git|dist|.next|__pycache__|.venv|coverage",
                        metavar="DIRS",
                        help="Pipe-separated directory names to skip")
    parser.add_argument("-o", "--output", default="bundle.md", metavar="FILE",
                        help="Output markdown filename (default: bundle.md)")
    parser.add_argument("--max-bytes", type=int, default=500_000, metavar="N",
                        help="Skip files larger than N bytes (default: 500000)")
    return parser.parse_args()


def matches_any(name: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(name, pat) for pat in patterns)


def collect_files(root: Path, patterns: list[str], excluded_dirs: set[str],
                  max_bytes: int) -> list[Path]:
    """Walk the tree and return matching files, sorted for determinism."""
    matches = []
    for dirpath, dirnames, filenames in os.walk(root):
        # Prune excluded dirs in-place so os.walk skips them entirely.
        dirnames[:] = sorted(
            d for d in dirnames if d not in excluded_dirs and not d.startswith(".")
        )
        for fname in sorted(filenames):
            if not matches_any(fname, patterns):
                continue
            fpath = Path(dirpath) / fname
            try:
                size = fpath.stat().st_size
            except OSError:
                continue
            if size > max_bytes:
                print(f"  [skip — too large {size:,}B] {fpath}", file=sys.stderr)
                continue
            matches.append(fpath)
    return matches


def read_text(path: Path) -> str | None:
    """Return file text or None if it's binary/unreadable."""
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        try:
            return path.read_text(encoding="latin-1")
        except Exception:
            return None
    except OSError as exc:
        print(f"  [skip — {exc}] {path}", file=sys.stderr)
        return None


def lang_hint(path: Path) -> str:
    return EXT_LANG.get(path.suffix.lower(), "")


def write_bundle(files: list[Path], root: Path, output: Path, max_bytes: int) -> int:
    """Write the markdown bundle. Returns the count of files written."""
    written = 0
    with output.open("w", encoding="utf-8") as out:
        out.write(f"# Source bundle\n\n")
        out.write(f"Generated from `{root.resolve()}`  \n")
        out.write(f"Patterns matched **{len(files)}** file(s)\n\n")
        out.write("---\n\n")

        for path in files:
            rel = path.relative_to(root)
            text = read_text(path)
            if text is None:
                print(f"  [skip — binary or unreadable] {path}", file=sys.stderr)
                continue

            lang = lang_hint(path)
            # Escape any triple-backtick sequences inside the file so they
            # don't break the outer fence.
            safe_text = text.replace("```", "` ` `")

            out.write(f"```{lang} {rel}\n")
            out.write(safe_text)
            if safe_text and not safe_text.endswith("\n"):
                out.write("\n")
            out.write("```\n\n")
            written += 1

    return written


def main():
    args = parse_args()
    root = Path(args.root).resolve()
    if not root.is_dir():
        sys.exit(f"Error: '{root}' is not a directory.")

    patterns = [p.strip() for p in args.patterns.split("|") if p.strip()]
    excluded_dirs = {d.strip() for d in args.exclude.split("|") if d.strip()}
    output = Path(args.output)

    # Refuse to overwrite the output file with itself if it happens to match
    # the pattern (edge case but real).
    output_abs = output.resolve()

    print(f"Scanning : {root}")
    print(f"Patterns : {patterns}")
    print(f"Excluding: {sorted(excluded_dirs)}")
    print(f"Output   : {output}")
    print()

    files = collect_files(root, patterns, excluded_dirs, args.max_bytes)

    # Never bundle the output file itself.
    files = [f for f in files if f.resolve() != output_abs]

    if not files:
        print("No files matched. Check your patterns or root directory.")
        sys.exit(0)

    print(f"Found {len(files)} file(s). Writing bundle…")
    written = write_bundle(files, root, output, args.max_bytes)
    size_kb = output.stat().st_size / 1024
    print(f"Done. {written} file(s) → {output} ({size_kb:.1f} KB)")


if __name__ == "__main__":
    main()