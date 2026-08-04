#!/usr/bin/env python3
"""
Find duplicate files by content hash (SHA-256).

Examples:
    python find_duplicate_files.py /path/to/dir
    python find_duplicate_files.py . --min-size-mb 1
    python find_duplicate_files.py . --no-skip-dirs
"""

import argparse
import hashlib
import os
import sys
from collections import defaultdict
from pathlib import Path

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
CHUNK_SIZE = 1024 * 1024


def file_sha256(path: Path) -> str | None:
    digest = hashlib.sha256()
    try:
        with path.open("rb") as handle:
            while True:
                chunk = handle.read(CHUNK_SIZE)
                if not chunk:
                    break
                digest.update(chunk)
        return digest.hexdigest()
    except (OSError, PermissionError) as exc:
        print(f"  [skip] {path}: {exc}", file=sys.stderr)
        return None


def find_duplicates(root: Path, min_size_bytes: int, skip_dirs: set[str]):
    # Group by size first to avoid hashing unique sizes.
    by_size: dict[int, list[Path]] = defaultdict(list)

    for current_root, dirnames, filenames in os.walk(root):
        if skip_dirs:
            dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for name in filenames:
            path = Path(current_root) / name
            try:
                size = path.stat().st_size
            except (OSError, PermissionError):
                continue
            if size >= min_size_bytes:
                by_size[size].append(path)

    groups = []
    for size, paths in by_size.items():
        if len(paths) < 2:
            continue
        by_hash: dict[str, list[Path]] = defaultdict(list)
        for path in paths:
            digest = file_sha256(path)
            if digest is not None:
                by_hash[digest].append(path)
        for digest, hashed_paths in by_hash.items():
            if len(hashed_paths) > 1:
                groups.append((size, digest, hashed_paths))

    groups.sort(key=lambda item: item[0], reverse=True)
    return groups


def human_mb(size_bytes: int) -> str:
    return f"{size_bytes / (1024 * 1024):.2f} MB"


def main():
    parser = argparse.ArgumentParser(
        description="Find duplicate files by content (SHA-256)."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory to scan (default: current directory)",
    )
    parser.add_argument(
        "--min-size-mb",
        type=float,
        default=0.0,
        help="Minimum file size in MB to consider (default: 0)",
    )
    parser.add_argument(
        "--no-skip-dirs",
        action="store_true",
        help="Do not skip common heavy directories (.git, node_modules, …)",
    )
    args = parser.parse_args()

    root = Path(args.directory)
    if not root.exists():
        print(f"Error: directory does not exist: {root}", file=sys.stderr)
        sys.exit(1)
    if not root.is_dir():
        print(f"Error: not a directory: {root}", file=sys.stderr)
        sys.exit(1)

    skip_dirs = set() if args.no_skip_dirs else set(DEFAULT_SKIP_DIRS)
    min_size_bytes = int(args.min_size_mb * 1024 * 1024)

    print(f"Scanning: {root.resolve()}")
    print(f"Min size: {args.min_size_mb} MB")
    if skip_dirs:
        print(f"Skipping: {', '.join(sorted(skip_dirs))}")
    print()

    groups = find_duplicates(root, min_size_bytes, skip_dirs)
    if not groups:
        print("No content-duplicate groups found.")
        return

    for size, digest, paths in groups:
        print(f"Duplicate content ({human_mb(size)}, sha256={digest[:12]}…)")
        for path in paths:
            print(f"  -> {path}")
        print("-" * 50)

    print(f"Found {len(groups)} duplicate group(s).")


if __name__ == "__main__":
    main()
