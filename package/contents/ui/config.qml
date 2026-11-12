/*
    SPDX-FileCopyrightText: 2026 MakrisJr
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.plasma.plasma5support as P5Support
import "span.js" as Span

ColumnLayout {
    id: root

    property var configDialog
    property var parentLayout

    property string cfg_Image
    property int cfg_FillMode
    property alias cfg_Color: colorButton.color

    readonly property string pluginId: "com.github.makrisjr.spannedimage"

    // True when the System Settings Wallpaper page handles "Set for all screens" for us.
    property bool claimedAllScreens: false
    // The Screen Locking settings page: one config already covers every screen there,
    // and the desktop-wide button below must not run (it would change desktop wallpapers).
    readonly property bool isLockScreen: !!configDialog && ("wallpaperIntegration" in configDialog)

    Component.onCompleted: claimedAllScreens = Span.claimAllScreens(configDialog)
    Component.onDestruction: {
        if (claimedAllScreens) {
            Span.releaseAllScreens(configDialog);
        }
    }

    spacing: Kirigami.Units.largeSpacing

    Kirigami.FormLayout {
        twinFormLayouts: root.parentLayout
        Layout.fillWidth: true

        RowLayout {
            Kirigami.FormData.label: "Image:"
            Layout.fillWidth: true

            QQC2.TextField {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 16
                readOnly: true
                placeholderText: "No image selected"
                text: root.cfg_Image === "" ? "" : decodeURIComponent(root.cfg_Image.replace(/^file:\/\//, ""))
            }
            QQC2.Button {
                icon.name: "document-open"
                text: "Browse…"
                onClicked: fileDialog.open()
            }
        }

        QQC2.ComboBox {
            id: fillModeBox
            Kirigami.FormData.label: "Positioning:"
            textRole: "text"
            valueRole: "value"
            implicitContentWidthPolicy: QQC2.ComboBox.WidestText
            model: [
                { text: "Fill all monitors (crop edges)", value: Image.PreserveAspectCrop },
                { text: "Fit inside all monitors (may leave bars)", value: Image.PreserveAspectFit },
                { text: "Stretch (ignore aspect ratio)", value: Image.Stretch },
            ]
            currentIndex: Math.max(0, indexOfValue(root.cfg_FillMode))
            onActivated: root.cfg_FillMode = currentValue
        }

        KQuickControls.ColorButton {
            id: colorButton
            Kirigami.FormData.label: "Background:"
            dialogTitle: "Select Background Color"
        }
    }

    LayoutPreview {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(Kirigami.Units.gridUnit * 18, width * area.height / area.width)
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        source: root.cfg_Image
        fillMode: root.cfg_FillMode
        backgroundColor: root.cfg_Color
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        // Separate window, so this page (and its live preview) stays open alongside it.
        QQC2.Button {
            icon.name: "preferences-desktop-display"
            text: "Arrange Monitors…"
            onClicked: KCMUtils.KCMLauncher.open(["kcm_kscreen"])
            QQC2.ToolTip.text: "Open Display Configuration to move your monitors. The preview above follows along."
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
        }

        QQC2.Button {
            // In the System Settings page, "Set for all screens" + Apply does the same job.
            visible: !root.claimedAllScreens && !root.isLockScreen
            icon.name: "view-fullscreen"
            text: "Use on all monitors"
            QQC2.ToolTip.text: "Plasma keeps a separate wallpaper per monitor. This puts this image on all of them."
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            enabled: root.cfg_Image !== ""
            onClicked: {
                const script = Span.applyAllScript(root.pluginId, root.cfg_Image, root.cfg_FillMode, root.cfg_Color.toString());
                const cmd = "qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript " + Span.shellQuote(script);
                applyStatus.text = "Applying…";
                executable.connectSource(cmd);
            }
        }
        QQC2.Label {
            id: applyStatus
            opacity: 0.7
        }
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            applyStatus.text = data["exit code"] === 0 ? "Applied to all monitors" : "Failed: " + (data.stderr || data["exit code"]);
            disconnectSource(sourceName);
        }
    }

    FileDialog {
        id: fileDialog
        title: "Choose an image to span across your monitors"
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.avif *.jxl *.bmp *.gif *.tif *.tiff *.heic *.heif)", "All files (*)"]
        onAccepted: root.cfg_Image = selectedFile.toString()
    }
}
