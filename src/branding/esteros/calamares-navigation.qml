/* esterOS navigation — pill next button with arrow
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Rectangle {
    id: navigationBar
    color: "#EBEBEB"
    height: 72
    radius: 32

    readonly property color accentColor: "#2563EB"
    readonly property color accentPressedColor: "#1D4ED8"
    readonly property color accentDisabledColor: "#93B4F5"

    RowLayout {
        id: buttonBar
        anchors.fill: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.bottomMargin: 20
        spacing: 12

        Button {
            id: quitButton
            visible: ViewManager.quitVisible
            enabled: ViewManager.quitEnabled
            flat: true
            text: ViewManager.quitLabel
            onClicked: ViewManager.quit()

            ToolTip.visible: hovered
            ToolTip.timeout: 5000
            ToolTip.delay: 1000
            ToolTip.text: ViewManager.quitTooltip

            background: Rectangle {
                radius: 18
                color: quitButton.hovered ? "#DDDDDD" : "transparent"
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Button {
            id: backButton
            visible: ViewManager.backAndNextVisible
            enabled: ViewManager.backEnabled
            implicitWidth: 56
            implicitHeight: 44
            onClicked: ViewManager.back()

            contentItem: Text {
                text: "\u2190"
                color: backButton.enabled ? "#1F1F1F" : "#888888"
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: height / 2
                color: backButton.enabled
                    ? (backButton.pressed ? "#C8C8C8" : (backButton.hovered ? "#D8D8D8" : "#E4E4E4"))
                    : "#ECECEC"
                border.width: 1
                border.color: backButton.enabled ? "#B8B8B8" : "#D0D0D0"
            }
        }

        Button {
            id: nextButton
            visible: ViewManager.backAndNextVisible
            enabled: ViewManager.nextEnabled
            implicitWidth: 56
            implicitHeight: 44
            onClicked: ViewManager.next()

            contentItem: Text {
                text: "\u2192"
                color: "#FFFFFF"
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: height / 2
                color: nextButton.enabled
                    ? (nextButton.pressed ? navigationBar.accentPressedColor : navigationBar.accentColor)
                    : navigationBar.accentDisabledColor
            }
        }
    }
}
