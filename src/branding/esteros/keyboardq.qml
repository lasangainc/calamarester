/* esterOS keyboard step
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
        sectionTitle: qsTr("Choose your keyboard layout")
        sectionDescription: qsTr("Select the keyboard layout you want to use.")

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#D8D8D8"
            radius: 20

            ScrollView {
                anchors.fill: parent
                anchors.margins: 12
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: config.keyboardLayoutsModel

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 44
                            text: model.label
                            flat: true
                            checkable: true
                            checked: config.keyboardLayoutsModel.currentIndex === index

                            onClicked: config.keyboardLayoutsModel.currentIndex = index

                            contentItem: Text {
                                text: parent.text
                                color: "#1F1F1F"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 13
                            }

                            background: Rectangle {
                                radius: height / 2
                                color: "#FFFFFF"
                                border.color: parent.checked ? "#7B9FD4" : "#E0E0E0"
                                border.width: parent.checked ? 2 : 1
                            }
                        }
                    }
                }
            }
        }
    }
}
