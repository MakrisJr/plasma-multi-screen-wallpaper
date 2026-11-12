#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 MakrisJr
# SPDX-License-Identifier: GPL-2.0-or-later
# Install (or update) the Spanned Image wallpaper plugin for the current user.
set -euo pipefail
cd "$(dirname "$0")"

ID=com.github.makrisjr.spannedimage
if kpackagetool6 -t Plasma/Wallpaper -s "$ID" >/dev/null 2>&1; then
    kpackagetool6 -t Plasma/Wallpaper -u package
else
    kpackagetool6 -t Plasma/Wallpaper -i package
fi

echo
echo "Installed. Right-click the desktop → Configure Desktop and Wallpaper → Wallpaper type: \"Spanned Image\"."
echo "If you updated an existing install, restart plasmashell to load the new code:"
echo "    systemctl --user restart plasma-plasmashell"
