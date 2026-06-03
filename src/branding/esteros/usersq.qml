/* esterOS users step
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
        sectionTitle: qsTr("Create your account")
        sectionDescription: qsTr("Pick a user name and credentials to log in and perform admin tasks.")

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width
                spacing: 14

                EsterOSPillField {
                    label: qsTr("What is your name?")
                    placeholderText: qsTr("Your full name")
                    text: config.fullName
                    enabled: config.isEditable("fullName")
                    onTextEdited: config.setFullName(text)
                }

                EsterOSPillField {
                    id: loginField
                    label: qsTr("What name do you want to use to log in?")
                    placeholderText: qsTr("Login name")
                    text: config.loginName
                    enabled: config.isEditable("loginName")
                    validator: RegularExpressionValidator { regularExpression: /[a-z_][a-z0-9_-]*[$]?$/ }
                    onTextEdited: {
                        if (loginField.fieldItem.acceptableInput) {
                            if (text === "root") {
                                forbiddenMessage.visible = true
                            } else {
                                config.setLoginName(text)
                                userMessage.visible = false
                                forbiddenMessage.visible = false
                            }
                        } else {
                            userMessage.visible = true
                        }
                    }
                }

                EsterOSPillField {
                    id: hostField
                    label: qsTr("What is the name of this computer?")
                    placeholderText: qsTr("Computer name")
                    text: config.hostname
                    validator: RegularExpressionValidator { regularExpression: /[a-zA-Z0-9][-a-zA-Z0-9_]+/ }
                    onTextEdited: {
                        if (hostField.fieldItem.acceptableInput) {
                            if (text === "localhost") {
                                forbiddenHost.visible = true
                            } else {
                                config.setHostName(text)
                                hostMessage.visible = false
                                forbiddenHost.visible = false
                            }
                        } else {
                            hostMessage.visible = true
                        }
                    }
                }

                EsterOSPillField {
                    id: passwordField
                    label: qsTr("Choose a password")
                    placeholderText: qsTr("Password")
                    text: config.userPassword
                    echoMode: TextInput.Password
                    onTextEdited: config.setUserPassword(text)
                }

                EsterOSPillField {
                    id: verifyPasswordField
                    label: qsTr("Repeat password")
                    placeholderText: qsTr("Repeat password")
                    text: config.userPasswordSecondary
                    echoMode: TextInput.Password
                    onTextEdited: {
                        if (passwordField.text === text) {
                            config.setUserPasswordSecondary(text)
                            passMessage.visible = false
                        } else {
                            passMessage.visible = true
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    visible: userMessage.visible
                    text: qsTr("Only lowercase letters, numbers, underscore and hyphen are allowed.")
                    color: "#BE5F68"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                Label {
                    id: userMessage
                    visible: false
                }

                Label {
                    id: forbiddenMessage
                    visible: false
                    Layout.fillWidth: true
                    text: qsTr("root is not allowed as username.")
                    color: "#BE5F68"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                Label {
                    id: hostMessage
                    visible: false
                }

                Label {
                    id: forbiddenHost
                    visible: false
                    Layout.fillWidth: true
                    text: qsTr("localhost is not allowed as hostname.")
                    color: "#BE5F68"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                Label {
                    id: passMessage
                    visible: false
                    Layout.fillWidth: true
                    text: config.userPasswordMessage
                    color: "#BE5F68"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                CheckBox {
                    visible: config.writeRootPassword
                    text: qsTr("Reuse user password as root password")
                    checked: config.reuseUserPasswordForRoot
                    onCheckedChanged: config.setReuseUserPasswordForRoot(checked)
                }

                CheckBox {
                    text: qsTr("Log in automatically without asking for the password")
                    checked: config.doAutoLogin
                    onCheckedChanged: config.setAutoLogin(checked)
                }
            }
        }
    }
}
