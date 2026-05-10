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

        function onButtonEvent(buttonId, pressed) {
            if (!pressed)
                return;

            switch (buttonId) {
            case 9: // LB
                bar.decrementCurrentIndex();
                break;
            case 10: // RB
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
            GP.ScrollHandler {
                flickable: flick
            }

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: rectangle.width
                contentHeight: rectangle.height

                Rectangle {
                    id: rectangle
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
                anchors.fill: parent

                ColumnLayout {
                    anchors.fill: parent
                    Button {
                        text: "button1"
                    }
                    Button {
                        text: "button2"
                    }
                    Label {
                        text: "text label"
                    }
                    Button {
                        text: "button3"
                    }
                }
            }
        }
    }
}
