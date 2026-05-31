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
        TabButton {
            text: "Scrollwheel"
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
                        text: "text label " + GP.Labels.south
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button3"
                    }
                }
            }
        }
        Item {
            GP.ScrollHandler {
                // TODO: make it accept a json object to represent a QPoint, or make it create that when the target isnt a flickable or scrollbar.
                //
                // This works as long as the center of the target item is visible, but fails once the item's center is not visible (outside the window, hidden behind a different item, etc)
                target: randbutton
            }

            Layout.fillHeight: true

            ScrollView {
                id: viewte
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                ColumnLayout {
                    anchors.fill: parent
                    Button {
                        text: "button1"
                    }
                    Button {
                        id: randbutton
                        text: "button2"
                    }
                    Label {
                        text: "text label " + GP.Labels.south
                    }
                    Button {
                        text: "button3"
                    }
                    Label {
                        text: "text\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\ntext\n"
                    }
                }
            }
        }
    }
}
