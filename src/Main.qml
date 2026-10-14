// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import io.github.rfrench3.controllable as GP

ApplicationWindow {
    visible: true

    header: TabBar {
        id: bar
        width: parent.width
        TabButton {
            text: "ScrollBar"
        }
        TabButton {
            text: "Flickable"
        }
        TabButton {
            text: "Page Nav"
        }
    }

    Connections {
        target: GP.Gamepad

        function onButtonPressed(buttonId) {
            switch (buttonId) {
            case GP.SDL_GAMEPAD.LEFT_SHOULDER:
                bar.decrementCurrentIndex();
                break;
            case GP.SDL_GAMEPAD.RIGHT_SHOULDER:
                bar.incrementCurrentIndex();
                break;
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: bar.currentIndex
        Item {
            id: homeTab
            GP.ScrollHandler {
                target: view.ScrollBar.vertical
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
            GP.ScrollHandler {
                target: flick
            }

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: rectangle.width
                contentHeight: rectangle.height

                Rectangle {
                    id: rectangle
                    anchors.fill: parent
                    width: 2000
                    height: 2000
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "lightsteelblue"
                        }
                        GradientStop {
                            position: 1.0
                            color: "blue"
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    text: "This text shows that horizontal movement functions properly!"
                }
            }
        }
        Item {
            id: tabThree
            GP.PageNavigation {
                targetScrollbar: viewt.ScrollBar.vertical
            }

            Layout.fillHeight: true

            ScrollView {
                id: viewt
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                ColumnLayout {
                    anchors.fill: parent
                    Button {
                        text: "button1"
                    }
                    Button {
                        text: "button2"
                    }
                    Label {
                        text: ["Controller labels", GP.Labels.south, GP.Labels.east, GP.Labels.west, GP.Labels.north].join(', ')
                    }
                    Repeater {
                        model: 12
                        delegate: Button {
                            required property int index
                            text: `Button ${index + 3}`
                        }
                    }
                }
            }
        }
    }
}
