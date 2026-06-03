/* esterOS install slideshow
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function onActivate() {
        presentation.currentSlide = 0;
    }

    function onLeave() {}

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#EBEBEB"

            Column {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ":)"
                    font.pixelSize: 48
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Installing esterOS…")
                    font.bold: true
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Please wait while the system is being set up.")
                    font.pixelSize: 13
                    color: "#555555"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
