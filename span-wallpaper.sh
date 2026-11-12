#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 MakrisJr
# SPDX-License-Identifier: GPL-2.0-or-later
# Set an image spanned across every monitor from the command line.
#   ./span-wallpaper.sh <image> [fill|fit|stretch] [background-color]
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "usage: $0 <image> [fill|fit|stretch] [background-color]" >&2
    exit 1
fi

img=$(realpath -- "$1")
[[ -f "$img" ]] || { echo "not a file: $img" >&2; exit 1; }

case "${2:-fill}" in
    fill)    mode=2 ;;  # Image.PreserveAspectCrop
    fit)     mode=1 ;;  # Image.PreserveAspectFit
    stretch) mode=0 ;;  # Image.Stretch
    *) echo "mode must be fill, fit or stretch" >&2; exit 1 ;;
esac
color=${3:-#000000}

# Build the script with JSON-escaped values so odd file names can't break it.
script=$(python3 - "$img" "$mode" "$color" <<'PY'
import json, pathlib, sys
img, mode, color = sys.argv[1:]
plugin = "com.github.makrisjr.spannedimage"
print(f"""
const plugin = {json.dumps(plugin)};
for (const d of desktops()) {{
    d.wallpaperPlugin = plugin;
    d.currentConfigGroup = ['Wallpaper', plugin, 'General'];
    d.writeConfig('Image', {json.dumps(pathlib.Path(img).as_uri())});
    d.writeConfig('FillMode', {json.dumps(mode)});
    d.writeConfig('Color', {json.dumps(color)});
}}
""")
PY
)

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script"
