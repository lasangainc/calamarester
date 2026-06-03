/* esterOS summary step
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
        sectionTitle: qsTr("Review your choices")
        sectionDescription: config.message

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width
                spacing: 12

                Repeater {
                    model: config.summaryModel

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: contentColumn.implicitHeight + 24
                        radius: 16
                        color: "#FFFFFF"
                        border.color: "#E0E0E0"
                        border.width: 1

                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: model.title
                                font.bold: true
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                color: "#1F1F1F"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.message
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                color: "#555555"
                            }
                        }
                    }
                }
            }
        }
    }
}
