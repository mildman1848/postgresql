#!/usr/bin/env python3
"""Generate high-entropy local secret files without printing secret values."""

from __future__ import annotations

import argparse
import os
import secrets
import string
import sys
from pathlib import Path

# URL/shell/YAML/database friendly while still very high entropy.
# 96 chars from 62 symbols is ~571 bits. That is comfortably beyond practical brute force.
DEFAULT_LENGTH = 96
MIN_LENGTH = 32
MAX_LENGTH = 256
ALPHABET = string.ascii_letters + string.digits


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a secure secret file")
    parser.add_argument("--path", required=True, help="Output secret file path")
    parser.add_argument("--length", type=int, default=DEFAULT_LENGTH, help=f"Secret length, default {DEFAULT_LENGTH}")
    parser.add_argument("--force", action="store_true", help="Overwrite existing file")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    path = Path(args.path)

    if args.length < MIN_LENGTH:
        print(f"ERROR: length {args.length} is too short; minimum is {MIN_LENGTH}", file=sys.stderr)
        return 2
    if args.length > MAX_LENGTH:
        print(f"ERROR: length {args.length} exceeds compatibility maximum {MAX_LENGTH}", file=sys.stderr)
        return 2

    if path.exists() and not args.force:
        print(f"SKIP: {path} already exists; use FORCE=1 to overwrite")
        return 0

    path.parent.mkdir(parents=True, exist_ok=True)
    secret_value = "".join(secrets.choice(ALPHABET) for _ in range(args.length))

    flags = os.O_WRONLY | os.O_CREAT | os.O_TRUNC
    fd = os.open(path, flags, 0o600)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(secret_value)
    finally:
        try:
            os.chmod(path, 0o600)
        except FileNotFoundError:
            pass

    print(f"OK: wrote {path} ({args.length} chars, mode 0600)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
