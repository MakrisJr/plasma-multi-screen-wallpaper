/*
    SPDX-FileCopyrightText: 2026 MakrisJr
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "span.js" as Span

// The whole image laid over the monitor layout, scaled to fit this item. Parts that
// land on a monitor are shown at full brightness; parts that fall in gaps are dimmed.
Item {
    id: preview

    property url source
    property int fillMode: Image.PreserveAspectCrop
    property color backgroundColor: "black"
    // Anything with name/virtualX/virtualY/width/height per entry.
    property var screens: Qt.application.screens
    property color borderColor: Kirigami.Theme.highlightColor

    readonly property var area: Span.virtualArea(screens)
    readonly property real ratio: Math.min(width / area.width, height / area.height)

    Item {
        id: box
        width: preview.area.width * preview.ratio
        height: preview.area.height * preview.ratio
        anchors.centerIn: parent

        Rectangle {
            anchors.fill: parent
            color: preview.backgroundColor
            opacity: 0.35
        }
        Image {
            anchors.fill: parent
            source: preview.source
            fillMode: preview.fillMode
            sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
            asynchronous: true
            autoTransform: true
            opacity: 0.25
        }

        Repeater {
            model: preview.screens
            delegate: Item {
                required property var modelData
                x: (modelData.virtualX - preview.area.x) * preview.ratio
                y: (modelData.virtualY - preview.area.y) * preview.ratio
                width: modelData.width * preview.ratio
                height: modelData.height * preview.ratio

                SpannedView {
                    anchors.fill: parent
                    source: preview.source
                    fillMode: preview.fillMode
                    backgroundColor: preview.backgroundColor
                    area: ({ x: 0, y: 0, width: box.width, height: box.height })
                    screenPos: Qt.point(parent.x, parent.y)
                    devicePixelRatio: Screen.devicePixelRatio
                }
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: preview.borderColor
                    border.width: 2
                }
                QQC2.Label {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: Kirigami.Units.smallSpacing
                    text: parent.modelData.name
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                }
            }
        }
    }
}
