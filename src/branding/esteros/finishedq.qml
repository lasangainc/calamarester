/* esterOS finished step
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import esteros 1.0

Item {
    anchors.fill: parent

    EsterOSFrame {
        anchors.fill: parent
        sectionTitle: qsTr("Installation completed")
        sectionDescription: qsTr("%1 has been installed on your computer. You may now restart into your new system, or continue using the Live environment.").arg(Branding.string(Branding.ProductName))

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Button {
                Layout.fillWidth: true
                implicitHeight: 44
                text: qsTr("Restart System")
                onClicked: config.doRestart(true)

                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 13
                }

                background: Rectangle {
                    radius: height / 2
                    color: parent.pressed ? "#6A8EC3" : "#7B9FD4"
                }
            }

            Button {
                Layout.fillWidth: true
                implicitHeight: 44
                flat: true
                text: qsTr("Close Installer")
                onClicked: ViewManager.quit()

                contentItem: Text {
                    text: parent.text
                    color: "#1F1F1F"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 13
                }

                background: Rectangle {
                    radius: height / 2
                    color: parent.hovered ? "#DDDDDD" : "transparent"
                    border.color: "#D8D8D8"
                    border.width: 1
                }
            }
        }
    }

    function onActivate() {}
    function onLeave() {}
}
