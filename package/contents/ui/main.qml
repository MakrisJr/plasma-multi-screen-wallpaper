/*
    SPDX-FileCopyrightText: 2026 MakrisJr
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import org.kde.plasma.plasmoid
import "span.js" as Span

WallpaperItem {
    id: root

    readonly property string imageSource: root.configuration.Image || ""

    // Dropping an image on the desktop uses it.
    onOpenUrlRequested: url => {
        root.configuration.Image = url.toString();
        root.configuration.writeConfig();
    }

    Component.onCompleted: {
        // Keep the splash screen up until the image is decoded.
        root.loading = root.imageSource !== "";
    }

    SpannedView {
        anchors.fill: parent
        source: root.imageSource
        fillMode: root.configuration.FillMode
        backgroundColor: root.configuration.Color
        area: Span.virtualArea(Qt.application.screens)
        screenPos: Qt.point(Screen.virtualX, Screen.virtualY)
        devicePixelRatio: Screen.devicePixelRatio

        onStatusChanged: {
            if (status !== Image.Loading) {
                root.loading = false;
            }
        }
    }
}
