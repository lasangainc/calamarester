/* esterOS install slideshow
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import QtQuick 2.0
import io.calamares.ui 1.0
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

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "file:/" + Branding.imagePath(Branding.ProductLogo)
                    sourceSize.width: 64
                    sourceSize.height: 64
                    width: 64
                    height: 64
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
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
