#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/../debtap"

pattern='\.files(\.[[:digit:]]{3})?$'

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

touch "$tmpdir/core.files"
touch "$tmpdir/extra.files.123"
touch "$tmpdir/invalid.files.12"
touch "$tmpdir/other.txt"

matches="$(find "$tmpdir" -maxdepth 1 -type f -printf '%f\n' | grep -E "$pattern" | sort)"

expected="$(printf '%s\n' core.files extra.files.123)"

if [[ "$matches" != "$expected" ]]; then
    echo "FAIL: Unexpected cache file matches"
    echo "Expected:"
    echo "$expected"
    echo "Got:"
    echo "$matches"
    exit 1
fi

if grep -Fq "grep -E '*.files?(.[[:digit:]]{3})'" "$SOURCE_FILE"; then
    echo "FAIL: Old broken regex still exists in debtap"
    exit 1
fi

if ! grep -Fq "grep -E '$pattern'" "$SOURCE_FILE"; then
    echo "FAIL: Corrected regex not found in debtap"
    exit 1
fi

echo "PASS: .files detected"
echo "PASS: .files.123 detected"
echo "PASS: Invalid suffix rejected"
echo "PASS: debtap uses corrected regex"
