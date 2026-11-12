#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 MakrisJr
# SPDX-License-Identifier: GPL-2.0-or-later
# Build the archive to upload to the KDE Store (store.kde.org → Plasma 6 Wallpaper Plugins).
# "Get New Plugins…" installs it with kpackage, which wants metadata.json at the archive root.
set -euo pipefail
cd "$(dirname "$0")"

version=$(python3 -c 'import json; print(json.load(open("package/metadata.json"))["KPlugin"]["Version"])')
out="dist/spanned-image-${version}.tar.gz"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
cp -r package/. "$stage/"
cp LICENSE "$stage/"

mkdir -p dist
tar --sort=name --owner=0 --group=0 --numeric-owner -czf "$out" -C "$stage" .
echo "Built $out"
tar -tzf "$out"
