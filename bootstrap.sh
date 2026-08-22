#!/bin/sh
# One-time, per clone: install git hooks and show what to do next.
set -eu
cd "$(dirname "$0")"
if command -v lefthook >/dev/null 2>&1; then
  lefthook install
else
  echo "lefthook not on PATH yet; run ./bootstrap.sh again after the first darwin-rebuild switch"
fi
echo "next: sudo darwin-rebuild switch --flake .#$(scutil --get LocalHostName 2>/dev/null || echo hephaestus)"
