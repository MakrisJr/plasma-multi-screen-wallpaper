.pragma library

// SPDX-FileCopyrightText: 2026 MakrisJr
// SPDX-License-Identifier: GPL-2.0-or-later

// Bounding box of every monitor in the virtual desktop, in logical pixels.
// `screens` is Qt.application.screens (or anything with virtualX/virtualY/width/height).
function virtualArea(screens) {
    if (!screens || screens.length === 0) {
        return { x: 0, y: 0, width: 1, height: 1 };
    }
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (let i = 0; i < screens.length; ++i) {
        const s = screens[i];
        minX = Math.min(minX, s.virtualX);
        minY = Math.min(minY, s.virtualY);
        maxX = Math.max(maxX, s.virtualX + s.width);
        maxY = Math.max(maxY, s.virtualY + s.height);
    }
    return { x: minX, y: minY, width: maxX - minX, height: maxY - minY };
}

// Plasma desktop script that switches every desktop to this plugin with the given settings.
function applyAllScript(pluginId, image, fillMode, color) {
    return "const plugin = " + JSON.stringify(pluginId) + ";"
        + "for (const d of desktops()) {"
        + "  d.wallpaperPlugin = plugin;"
        + "  d.currentConfigGroup = ['Wallpaper', plugin, 'General'];"
        + "  d.writeConfig('Image', " + JSON.stringify(image) + ");"
        + "  d.writeConfig('FillMode', " + JSON.stringify(String(fillMode)) + ");"
        + "  d.writeConfig('Color', " + JSON.stringify(String(color)) + ");"
        + "}";
}

// While a Spanned Image config page is open in the Wallpaper KCM, force its
// "Set for all screens" switch on, then put back what the user had once the
// last page goes away (another wallpaper type picked, or the KCM closed).
// Counted, because the KCM creates a hidden throwaway copy of the page and only
// destroys it after the real page has been created.
let allScreensUsers = 0;
let allScreensSaved = false;

function hasAllScreens(dialog) {
    return !!dialog && ("allScreens" in dialog);
}

function claimAllScreens(dialog) {
    if (!hasAllScreens(dialog)) {
        return false;
    }
    if (allScreensUsers === 0) {
        allScreensSaved = dialog.allScreens;
    }
    allScreensUsers++;
    dialog.allScreens = true;
    return true;
}

function releaseAllScreens(dialog) {
    if (allScreensUsers === 0) {
        return;
    }
    allScreensUsers--;
    if (allScreensUsers === 0) {
        try {
            if (hasAllScreens(dialog)) {
                dialog.allScreens = allScreensSaved;
            }
        } catch (e) {
            // The KCM itself is being torn down; nothing to restore.
        }
    }
}

// Quote a string for /bin/sh.
function shellQuote(s) {
    return "'" + String(s).replace(/'/g, "'\\''") + "'";
}
