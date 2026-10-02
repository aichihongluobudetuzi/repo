#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p debs

dpkg-scanpackages -m debs /dev/null > Packages.raw

python3 - <<'PY'
from collections import defaultdict
from pathlib import Path

raw = Path("Packages.raw").read_text()
stanzas = [s for s in raw.strip().split("\n\n") if s.strip()]

def field(stanza: str, name: str):
    prefix = name + ": "
    for line in stanza.split("\n"):
        if line.startswith(prefix):
            return line[len(prefix):]
    return None

def set_field(stanza: str, name: str, value: str) -> str:
    prefix = name + ": "
    lines = stanza.split("\n")
    for i, line in enumerate(lines):
        if line.startswith(prefix):
            lines[i] = prefix + value
            return "\n".join(lines)
    lines.append(prefix + value)
    return "\n".join(lines)

by_name = defaultdict(list)
for i, stanza in enumerate(stanzas):
    name = field(stanza, "Name") or field(stanza, "Package") or ""
    by_name[name].append(i)

for name, indexes in by_name.items():
    if len(indexes) < 2 or not name:
        continue
    for i in indexes:
        version = field(stanzas[i], "Version") or ""
        stanzas[i] = set_field(stanzas[i], "Name", f"{name} {version}".strip())

Path("Packages").write_text("\n\n".join(stanzas) + "\n")
PY

rm -f Packages.raw
gzip -9n -c Packages > Packages.gz
bzip2 -9 -c Packages > Packages.bz2

hash_line() {
  local algo="$1" file="$2"
  local sum size
  size="$(wc -c < "$file" | tr -d ' ')"
  case "$algo" in
    md5) sum="$(md5sum "$file" | awk '{print $1}')" ;;
    sha1) sum="$(sha1sum "$file" | awk '{print $1}')" ;;
    sha256) sum="$(sha256sum "$file" | awk '{print $1}')" ;;
  esac
  printf ' %s %s %s\n' "$sum" "$size" "$file"
}

{
  cat <<EOF
Origin: 三七
Label: 三七
Suite: stable
Version: $(date -u +%Y%m%d%H%M%S)
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 三七软件源
Date: $(date -Ru)
MD5Sum:
EOF
  hash_line md5 Packages
  hash_line md5 Packages.gz
  hash_line md5 Packages.bz2
  echo 'SHA1:'
  hash_line sha1 Packages
  hash_line sha1 Packages.gz
  hash_line sha1 Packages.bz2
  echo 'SHA256:'
  hash_line sha256 Packages
  hash_line sha256 Packages.gz
  hash_line sha256 Packages.bz2
} > Release
