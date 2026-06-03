/* esterOS welcome step
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
        sectionTitle: qsTr("Get started using esterOS")
        sectionDescription: qsTr("This wizard will help you install esterOS to your computer.")
    }

    Loader {
        anchors.fill: parent
        active: !config.requirementsModel.satisfiedRequirements
        source: "qrc:/Requirements.qml"
    }
}
