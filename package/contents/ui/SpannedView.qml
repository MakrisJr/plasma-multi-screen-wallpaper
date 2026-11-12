/*
    SPDX-FileCopyrightText: 2026 MakrisJr
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

// Shows the part of `source` that falls on one monitor, as if the image were laid
// over the bounding box of all monitors (`area`) using `fillMode`.
Item {
    id: view

    property url source
    property int fillMode: Image.PreserveAspectCrop
    property color backgroundColor: "black"
    // Bounding box of all monitors, in logical px: {x, y, width, height}
    property var area: ({ x: 0, y: 0, width: width, height: height })
    // Top-left corner of this monitor in the same coordinate space
    property point screenPos: Qt.point(0, 0)
    property real devicePixelRatio: 1

    readonly property alias status: image.status

    clip: true

    Rectangle {
        anchors.fill: parent
        color: view.backgroundColor
    }

    Image {
        id: image
        x: view.area.x - view.screenPos.x
        y: view.area.y - view.screenPos.y
        width: view.area.width
        height: view.area.height
        source: view.source
        fillMode: view.fillMode
        // Decode only as many pixels as the combined monitors need.
        sourceSize: Qt.size(Math.ceil(view.area.width * view.devicePixelRatio),
                            Math.ceil(view.area.height * view.devicePixelRatio))
        asynchronous: true
        autoTransform: true
        smooth: true
        cache: false
    }
}
