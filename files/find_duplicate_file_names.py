#!/usr/bin/env python3
"""
Find duplicate basenames (same filename, different paths).

This does NOT compare file contents — use find_duplicate_files.py for that.

Examples:
    python find_duplicate_file_names.py /path/to/dir
    python find_duplicate_file_names.py . -s 10
"""

import argparse
import os
import sys
from collections import defaultdict


def find_duplicate_names(target_directory, min_size_mb):
    min_size_bytes = min_size_mb * 1024 * 1024
    files_by_name = defaultdict(list)

    print(
        f"Scanning '{target_directory}' for duplicate basenames "
        f"(files ≥ {min_size_mb} MB)...\n"
    )

    for root, _, filenames in os.walk(target_directory):
        for filename in filenames:
            full_path = os.path.join(root, filename)
            try:
                file_size = os.path.getsize(full_path)
                if file_size >= min_size_bytes:
                    files_by_name[filename].append((full_path, file_size))
            except (OSError, PermissionError):
                continue

    duplicate_count = 0
    for filename, entries in files_by_name.items():
        if len(entries) > 1:
            duplicate_count += 1
            print(f"Duplicate basename: {filename}")
            for path, size_bytes in entries:
                size_mb = size_bytes / (1024 * 1024)
                print(f"  -> {path} ({size_mb:.2f} MB)")
            print("-" * 50)

    if duplicate_count == 0:
        print("No duplicate basenames found matching those criteria.")
    else:
        print(f"Scan complete. Found {duplicate_count} duplicate basename group(s).")


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Find files that share the same basename (filename only), "
            "not content. For content duplicates, use find_duplicate_files.py."
        )
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory to scan (default: current directory)",
    )
    parser.add_argument(
        "-s",
        "--size",
        type=float,
        default=1.0,
        help="Minimum file size in MB to consider (default: 1.0)",
    )
    args = parser.parse_args()

    if not os.path.exists(args.directory):
        print(f"Error: The directory '{args.directory}' does not exist.", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(args.directory):
        print(f"Error: '{args.directory}' is a file, not a directory.", file=sys.stderr)
        sys.exit(1)

    find_duplicate_names(args.directory, args.size)


if __name__ == "__main__":
    main()
