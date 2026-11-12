/*
    SPDX-FileCopyrightText: 2026 MakrisJr
    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Renders SpannedView for a fake monitor layout and saves the composite.
//   QT_QPA_PLATFORM=offscreen qml6 test/harness.qml -- <image> <out.png> <fillMode> <layout-json>
import QtQuick
import QtQuick.Window
import "../package/contents/ui"
import "../package/contents/ui/span.js" as Span

Window {
    id: win
    readonly property var args: Qt.application.arguments.slice(Qt.application.arguments.indexOf("--") + 1)
    readonly property var screens: JSON.parse(args[3])
    readonly property var area: Span.virtualArea(screens)
    width: area.width
    height: area.height
    visible: true
    color: "magenta"   // anything magenta in the output = not covered by any monitor

    Repeater {
        id: rep
        model: win.screens
        delegate: SpannedView {
            required property var modelData
            x: modelData.virtualX - win.area.x
            y: modelData.virtualY - win.area.y
            width: modelData.width
            height: modelData.height
            source: Qt.resolvedUrl("file://" + win.args[0])
            fillMode: parseInt(win.args[2])
            backgroundColor: "black"
            area: win.area
            screenPos: Qt.point(modelData.virtualX, modelData.virtualY)
        }
    }

    Timer {
        interval: 200; repeat: true; running: true
        onTriggered: {
            for (let i = 0; i < rep.count; ++i)
                if (rep.itemAt(i).status !== Image.Ready) return;
            running = false;
            win.contentItem.grabToImage(r => { r.saveToFile(win.args[1]); Qt.quit(); });
        }
    }
}
