#!/usr/bin/env python3
"""
extract-config.py — pull the embedded Psiphon network config out of an
official Conduit release binary.

The official Conduit binary (downloadable from
https://github.com/Psiphon-Inc/conduit/releases) embeds its psiphon_config.json
via Go's //go:embed directive. This script finds that JSON blob inside the
binary and writes it to a file. This is just copying data that's already
in the binary you downloaded — it's not bypassing anything.

Usage:
    python3 extract-config.py /path/to/official/conduit-binary > psiphon_config.json

Works on macOS, Linux, and Windows. Requires Python 3 (already installed on
macOS and most Linux distros).
"""

import json
import re
import sys


def extract(path: str) -> bytes:
    with open(path, "rb") as f:
        data = f.read()

    needle = b'"PropagationChannelId"'
    pos = data.find(needle)
    if pos == -1:
        raise SystemExit(
            f"Could not find Psiphon config inside {path}. "
            "Are you sure this is an official Conduit binary?"
        )

    # Walk backward to the opening brace of the JSON object.
    start = data.rfind(b"{", 0, pos)
    if start == -1:
        raise SystemExit("Found marker but no opening brace before it.")

    # Walk forward, balancing braces and respecting string boundaries.
    depth = 0
    in_str = False
    esc = False
    end = None
    for i in range(start, len(data)):
        c = data[i : i + 1]
        if esc:
            esc = False
            continue
        if c == b"\\" and in_str:
            esc = True
            continue
        if c == b'"':
            in_str = not in_str
            continue
        if in_str:
            continue
        if c == b"{":
            depth += 1
        elif c == b"}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break

    if end is None:
        raise SystemExit("Could not find end of JSON object.")

    blob = data[start:end]
    # Validate it parses.
    try:
        json.loads(blob)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Extracted bytes don't parse as JSON: {exc}")

    return blob


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__.strip(), file=sys.stderr)
        sys.exit(1)
    blob = extract(sys.argv[1])
    sys.stdout.buffer.write(blob)
    sys.stdout.buffer.write(b"\n")


if __name__ == "__main__":
    main()
