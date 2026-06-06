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

    function updatePasswordFeedback() {
        if (passwordField.text.length === 0 && verifyPasswordField.text.length === 0) {
            passMessage.visible = false
            validityMessage.visible = false
            return
        }
        if (passwordField.text !== verifyPasswordField.text) {
            passMessage.visible = true
            validityMessage.visible = false
            return
        }
        passMessage.visible = false
        validityMessage.visible = passwordField.text.length > 0
    }

    function updateRootPasswordFeedback() {
        if (!config.writeRootPassword || reusePasswordCheck.checked) {
            rootPassMessage.visible = false
            rootValidityMessage.visible = false
            return
        }
        if (rootPasswordField.text.length === 0 && verifyRootPasswordField.text.length === 0) {
            rootPassMessage.visible = false
            rootValidityMessage.visible = false
            return
        }
        if (rootPasswordField.text !== verifyRootPasswordField.text) {
            rootPassMessage.visible = true
            rootValidityMessage.visible = false
            return
        }
        rootPassMessage.visible = false
        rootValidityMessage.visible = rootPasswordField.text.length > 0
    }

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
                                userMessage.visible = false
                            } else {
                                config.setLoginName(text)
                                userMessage.visible = false
                                forbiddenMessage.visible = false
                            }
                        } else {
                            userMessage.visible = true
                            forbiddenMessage.visible = false
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
                                hostMessage.visible = false
                            } else {
                                config.setHostName(text)
                                hostMessage.visible = false
                                forbiddenHost.visible = false
                            }
                        } else {
                            hostMessage.visible = true
                            forbiddenHost.visible = false
                        }
                    }
                }

                EsterOSPillField {
                    id: passwordField
                    label: qsTr("Choose a password")
                    placeholderText: qsTr("Password")
                    text: config.userPassword
                    echoMode: TextInput.Password
                    onTextEdited: {
                        config.setUserPassword(text)
                        config.setUserPasswordSecondary(verifyPasswordField.text)
                        updatePasswordFeedback()
                    }
                }

                EsterOSPillField {
                    id: verifyPasswordField
                    label: qsTr("Repeat password")
                    placeholderText: qsTr("Repeat password")
                    text: config.userPasswordSecondary
                    echoMode: TextInput.Password
                    onTextEdited: {
                        config.setUserPasswordSecondary(text)
                        updatePasswordFeedback()
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
                    Layout.fillWidth: true
                    text: qsTr("Only letters, numbers, underscore and hyphen are allowed, minimal of two characters.")
                    color: "#BE5F68"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
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

                Label {
                    id: validityMessage
                    visible: false
                    Layout.fillWidth: true
                    text: config.userPasswordMessage
                    color: config.userPasswordValidity ? "#BE5F68" : "#4A7C59"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                CheckBox {
                    id: reusePasswordCheck
                    visible: config.writeRootPassword
                    text: qsTr("Reuse user password as root password")
                    checked: config.reuseUserPasswordForRoot
                    onCheckedChanged: {
                        config.setReuseUserPasswordForRoot(checked)
                        updateRootPasswordFeedback()
                    }
                }

                EsterOSPillField {
                    id: rootPasswordField
                    visible: config.writeRootPassword && !reusePasswordCheck.checked
                    label: qsTr("Choose a root password")
                    placeholderText: qsTr("Root password")
                    text: config.rootPassword
                    echoMode: TextInput.Password
                    onTextEdited: {
                        config.setRootPassword(text)
                        config.setRootPasswordSecondary(verifyRootPasswordField.text)
                        updateRootPasswordFeedback()
                    }
                }

                EsterOSPillField {
                    id: verifyRootPasswordField
                    visible: config.writeRootPassword && !reusePasswordCheck.checked
                    label: qsTr("Repeat root password")
                    placeholderText: qsTr("Repeat root password")
                    text: config.rootPasswordSecondary
                    echoMode: TextInput.Password
                    onTextEdited: {
                        config.setRootPasswordSecondary(text)
                        updateRootPasswordFeedback()
                    }
                }

                Label {
                    id: rootPassMessage
                    visible: false
                    Layout.fillWidth: true
                    text: config.rootPasswordMessage
                    color: "#BE5F68"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                Label {
                    id: rootValidityMessage
                    visible: false
                    Layout.fillWidth: true
                    text: config.rootPasswordMessage
                    color: config.rootPasswordValidity ? "#BE5F68" : "#4A7C59"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 11
                }

                CheckBox {
                    text: qsTr("Log in automatically without asking for the password")
                    checked: config.doAutoLogin
                    onCheckedChanged: config.setAutoLogin(checked)
                }
            }
        }
    }

    Connections {
        target: config
        function onUserPasswordStatusChanged() { updatePasswordFeedback() }
        function onRootPasswordStatusChanged() { updateRootPasswordFeedback() }
    }
}
