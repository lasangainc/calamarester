/* Pill-shaped text field for esterOS forms
   SPDX-FileCopyrightText: no
   SPDX-License-Identifier: CC0-1.0
*/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property alias label: fieldLabel.text
    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property alias validator: field.validator
    property alias echoMode: field.echoMode
    property alias fieldItem: field
    property alias enabled: field.enabled

    property color fillColor: "#FFFFFF"
    property color borderColor: "#D8D8D8"

    signal textEdited(string text)

    Label {
        id: fieldLabel
        Layout.fillWidth: true
        font.pixelSize: 12
        color: "#1F1F1F"
    }

    TextField {
        id: field
        Layout.fillWidth: true
        implicitHeight: 40
        leftPadding: 18
        rightPadding: 18
        font.pixelSize: 13
        color: "#1F1F1F"
        onTextChanged: root.textEdited(text)

        background: Rectangle {
            radius: height / 2
            color: root.fillColor
            border.color: field.activeFocus ? "#7B9FD4" : root.borderColor
            border.width: 1
        }
    }
}
