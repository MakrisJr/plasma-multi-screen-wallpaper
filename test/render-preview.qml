/*
    SPDX-FileCopyrightText: 2026 MakrisJr
    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Renders the settings page's LayoutPreview for a given monitor layout, e.g. for the store logo.
//   QT_QPA_PLATFORM=offscreen QT_SCALE_FACTOR=2 qml6 test/render-preview.qml -- \
//       <image> <out.png> <layout-json> [size=500] [margin=20] [border=#009014] [page=#ffffff]
// The output is size × QT_SCALE_FACTOR pixels square.
import QtQuick
import QtQuick.Window
import "../package/contents/ui"

Window {
    id: win
    readonly property var args: Qt.application.arguments.slice(Qt.application.arguments.indexOf("--") + 1)
    readonly property int size: parseInt(args[3] || "500")
    readonly property int margin: parseInt(args[4] || "20")
    width: size
    height: size
    visible: true

    Rectangle {
        id: page
        anchors.fill: parent
        color: win.args[6] || "#ffffff"

        LayoutPreview {
            id: preview
            anchors.fill: parent
            anchors.margins: win.margin
            source: Qt.resolvedUrl("file://" + win.args[0])
            screens: JSON.parse(win.args[2])
            borderColor: win.args[5] || "#009014"
        }
    }

    Timer {
        interval: 1500; running: true
        onTriggered: page.grabToImage(r => { r.saveToFile(win.args[1]); Qt.quit(); })
    }
}
