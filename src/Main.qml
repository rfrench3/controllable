// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import io.github.rfrench3.controllable as Gamepad

ApplicationWindow {
    visible: true

    header: TabBar {
        id: bar
        width: parent.width
        TabButton {
            text: qsTr("Home")
        }
        TabButton {
            text: qsTr("Discover")
        }
    }

    Connections {
        target: Gamepad.Gamepad

        function onButtonPressed(buttonId, button_down) {
            if (!button_down) return;

            if (buttonId == 0) {
                bar.currentIndex = 0
            }
            if (buttonId == 1) {
                bar.currentIndex = 1
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: bar.currentIndex
        Item {
            id: homeTab
            Gamepad.ScrollHandler {
                scrollBar: view.ScrollBar.vertical
            }

            Layout.fillHeight: true


            ScrollView {
                id: view
                anchors.fill: parent
                ListView {
                    model: 20
                    delegate: ItemDelegate {
                        text: "Item " + index

                        required property int index
                    }
                }
            }
        }
        Item {
            id: discoverTab
            Gamepad.ScrollHandler {
                flickable: flick
            }

            Flickable {
                id: flick

                contentWidth: rectangle.width
                contentHeight: rectangle.height


                Rectangle {
                    id: rectangle
                    width: 4000; height: 4000
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "lightsteelblue" }
                        GradientStop { position: 1.0; color: "blue" }
                    }
                }


            }

        }
    }


}
