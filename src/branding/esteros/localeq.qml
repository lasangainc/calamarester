/* esterOS locale step
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import "."

Item {
    anchors.fill: parent

    function onActivate() {}

    EsterOSFrame {
        anchors.fill: parent
        sectionTitle: qsTr("Choose your language")
        sectionDescription: qsTr("Select the language and regional settings for your system.")

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#D8D8D8"
            radius: 20

            ListView {
                id: localeList
                anchors.fill: parent
                anchors.margins: 12
                clip: true
                spacing: 10
                model: config.supportedLocales

                delegate: Item {
                    width: localeList.width
                    height: 44

                    Button {
                        anchors.fill: parent
                        text: modelData
                        flat: true
                        checkable: true
                        checked: config.currentLanguageCode === modelData

                        onClicked: config.currentLanguageCode = modelData

                        contentItem: Text {
                            text: parent.text
                            color: "#1F1F1F"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                        }

                        background: Rectangle {
                            radius: height / 2
                            color: parent.checked ? "#FFFFFF" : (parent.hovered ? "#F5F5F5" : "#FFFFFF")
                            border.color: parent.checked ? "#7B9FD4" : "#E0E0E0"
                            border.width: parent.checked ? 2 : 1
                        }
                    }
                }
            }
        }
    }
}
