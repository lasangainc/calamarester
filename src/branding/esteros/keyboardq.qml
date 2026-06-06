/* esterOS keyboard step
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

    EsterOSFrame {
        anchors.fill: parent
        sectionTitle: qsTr("Choose your keyboard layout")
        sectionDescription: qsTr("Select the keyboard layout and variant you want to use.")

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 180
                color: "#D8D8D8"
                radius: 20

                ListView {
                    id: layoutList
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    spacing: 10
                    model: config.keyboardLayoutsModel

                    delegate: Item {
                        width: layoutList.width
                        height: 44

                        Button {
                            anchors.fill: parent
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

            Label {
                Layout.fillWidth: true
                text: qsTr("Variant")
                font.pixelSize: 12
                color: "#1F1F1F"
                visible: config.keyboardVariantsModel.count > 1
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#D8D8D8"
                radius: 20
                visible: config.keyboardVariantsModel.count > 1

                ListView {
                    id: variantList
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    spacing: 10
                    model: config.keyboardVariantsModel

                    delegate: Item {
                        width: variantList.width
                        height: 44

                        Button {
                            anchors.fill: parent
                            text: model.label
                            flat: true
                            checkable: true
                            checked: config.keyboardVariantsModel.currentIndex === index

                            onClicked: config.keyboardVariantsModel.currentIndex = index

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
