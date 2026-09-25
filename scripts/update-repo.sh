#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p debs

dpkg-scanpackages -m debs /dev/null > Packages
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
  cat <<'EOF'
Origin: 三七
Label: 三七
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e
Components: main
Description: 三七软件源
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
