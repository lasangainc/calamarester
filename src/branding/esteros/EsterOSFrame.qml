/* Shared esterOS step frame
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import io.calamares.ui 1.0

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Item {
    id: root
    anchors.fill: parent

    property alias sectionTitle: titleText.text
    property alias sectionDescription: descText.text
    default property alias content: contentArea.data

    readonly property color cardColor: "#EBEBEB"
    readonly property color textColor: "#1F1F1F"
    readonly property color mutedTextColor: "#555555"
    readonly property color accentColor: "#7B9FD4"
    readonly property color fieldColor: "#FFFFFF"
    readonly property color fieldBorderColor: "#D8D8D8"

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        anchors.topMargin: 36
        anchors.bottomMargin: 8
        spacing: 12

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "file:/" + Branding.imagePath(Branding.ProductLogo)
            sourceSize.width: 64
            sourceSize.height: 64
            width: 64
            height: 64
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        Text {
            id: titleText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            font.pixelSize: 20
            wrapMode: Text.WordWrap
            color: root.textColor
        }

        Text {
            id: descText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            color: root.mutedTextColor
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                id: contentArea
                anchors.fill: parent
                spacing: 16
            }
        }
    }
}
