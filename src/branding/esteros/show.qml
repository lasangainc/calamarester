/* esterOS install slideshow
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import QtQuick 2.0
import io.calamares.ui 1.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    readonly property int emblemMaxSize: 128
    readonly property int emblemMinSize: 48
    readonly property int emblemSize: {
        var steps = ViewManager.rowCount()
        if (steps <= 1)
            return emblemMaxSize
        var progress = ViewManager.currentStepIndex / (steps - 1)
        return Math.round(emblemMaxSize - (emblemMaxSize - emblemMinSize) * progress)
    }

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
                    sourceSize.width: presentation.emblemSize
                    sourceSize.height: presentation.emblemSize
                    width: presentation.emblemSize
                    height: presentation.emblemSize
                    fillMode: Image.PreserveAspectFit
                    mipmap: true

                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Installing OriginUI…")
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
