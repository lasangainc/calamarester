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

    readonly property color accentColor: "#7B9FD4"
    readonly property bool isWelcomeStep: ViewManager.currentStepIndex === 0

    RowLayout {
        id: buttonBar
        anchors.fill: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.bottomMargin: 20
        spacing: 12

        Item {
            Layout.fillWidth: true
            visible: !navigationBar.isWelcomeStep
        }

        Button {
            id: backButton
            visible: ViewManager.backAndNextVisible && !navigationBar.isWelcomeStep
            enabled: ViewManager.backEnabled
            implicitWidth: 44
            implicitHeight: 44
            flat: true
            display: AbstractButton.IconOnly
            icon.name: ViewManager.backIcon
            onClicked: ViewManager.back()

            background: Rectangle {
                radius: 22
                color: backButton.hovered ? "#DDDDDD" : "transparent"
            }
        }

        Item {
            Layout.fillWidth: navigationBar.isWelcomeStep
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
                    ? (nextButton.pressed ? "#6A8EC3" : navigationBar.accentColor)
                    : "#B0B0B0"
            }
        }

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
    }
}
