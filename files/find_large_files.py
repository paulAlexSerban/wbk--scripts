#!/usr/bin/env python3
"""
Find files larger than a given size under a directory.

Skips common heavy directories (.git, node_modules, …) by default.

Examples:
    python find_large_files.py /path/to/directory --min-size-mb 500
    python find_large_files.py . --min-size-mb 50 --no-skip-dirs
"""

import argparse
import os
from pathlib import Path

UNITS = ["B", "KB", "MB", "GB", "TB"]
DEFAULT_SKIP_DIRS = {
    ".git",
    "node_modules",
    ".venv",
    "__pycache__",
    ".next",
    "dist",
    "build",
    "coverage",
}


def human_readable_size(size_bytes: int) -> str:
    size = float(size_bytes)
    unit_index = 0

    while size >= 1024 and unit_index < len(UNITS) - 1:
        size /= 1024
        unit_index += 1

    return f"{size:.2f} {UNITS[unit_index]}"


def find_large_files(root_dir: str, min_size_mb: float, skip_dirs: set[str]):
    min_size_bytes = min_size_mb * 1024 * 1024
    results = []

    for current_root, dirnames, files in os.walk(root_dir):
        if skip_dirs:
            dirnames[:] = [d for d in dirnames if d not in skip_dirs]

        for file_name in files:
            file_path = Path(current_root) / file_name

            try:
                size_bytes = file_path.stat().st_size
                if size_bytes >= min_size_bytes:
                    results.append((file_path, size_bytes))
            except (PermissionError, FileNotFoundError, OSError):
                continue

    results.sort(key=lambda x: x[1], reverse=True)
    return results


def main():
    parser = argparse.ArgumentParser(
        description="List files larger than a specified size."
    )
    parser.add_argument("directory", help="Root directory to scan")
    parser.add_argument(
        "--min-size-mb",
        type=float,
        default=100,
        help="Minimum file size in MB (default: 100)",
    )
    parser.add_argument(
        "--no-skip-dirs",
        action="store_true",
        help="Do not skip common heavy directories (.git, node_modules, …)",
    )
    args = parser.parse_args()

    root_dir = Path(args.directory)
    if not root_dir.exists():
        print(f"Directory does not exist: {root_dir}")
        return
    if not root_dir.is_dir():
        print(f"Not a directory: {root_dir}")
        return

    skip_dirs = set() if args.no_skip_dirs else set(DEFAULT_SKIP_DIRS)

    print(f"Scanning: {root_dir}")
    print(f"Minimum file size: {args.min_size_mb} MB")
    if skip_dirs:
        print(f"Skipping dirs: {', '.join(sorted(skip_dirs))}")
    print("-" * 80)

    large_files = find_large_files(str(root_dir), args.min_size_mb, skip_dirs)

    if not large_files:
        print("No files found.")
        return

    total_size = 0
    for file_path, size_bytes in large_files:
        total_size += size_bytes
        print(f"{human_readable_size(size_bytes):>12}  {file_path}")

    print("-" * 80)
    print(f"Files found: {len(large_files)}")
    print(f"Total size : {human_readable_size(total_size)}")


if __name__ == "__main__":
    main()
