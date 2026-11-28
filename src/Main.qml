// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import io.github.rfrench3.controllable as GP

ApplicationWindow {
    visible: true

    GP.GamepadSupport {
        fallbackTarget: root
    }

    header: TabBar {
        id: bar
        width: parent.width

        Keys.onDownPressed: event => {
            const currentTab = root.itemAt(root.currentIndex);
            const target = currentTab.nextItemInFocusChain(true);

            if (target && GP.QmlUtils.isDescendentOf(target, currentTab)) {
                target.forceActiveFocus(Qt.TabFocusReason);
            } else {
                currentTab.forceActiveFocus(Qt.TabFocusReason);
            }

            event.accepted = true;
        }

        Repeater {
            model: root.children

            TabButton {
                required property Item modelData
                required property int index
                text: modelData.title ?? "Page %1".arg(index)
            }
        }
    }

    // Set focus: true on the root Item of the application (this cannot be an ApplicationWindow)
    // as well as on the first item within each page/FocusScope
    StackLayout {
        id: root
        anchors.fill: parent
        currentIndex: bar.currentIndex

        focus: true
        Keys.onPressed: event => {
            if (event.key === GP.GamepadKeys.BACK)
                Qt.exit(0);

            if (event.key === GP.GamepadKeys.LEFT_BUMPER) {
                bar.decrementCurrentIndex();
                event.accepted = true;
                return;
            }

            if (event.key === GP.GamepadKeys.RIGHT_BUMPER) {
                bar.incrementCurrentIndex();
                event.accepted = true;
                return;
            }

            if (event.key === GP.GamepadKeys.DOWN) {
                const currentTab = root.itemAt(root.currentIndex) as FocusScope;
                const target = currentTab.nextItemInFocusChain(true);

                if (target && GP.QmlUtils.isDescendentOf(target, currentTab)) {
                    target.forceActiveFocus(Qt.TabFocusReason);
                } else {
                    currentTab.forceActiveFocus(Qt.TabFocusReason);
                }

                event.accepted = true;
                return;
            }
        }

        FocusScope {
            id: homeTab
            readonly property string title: "ListView"
            GP.ScrollHandler {
                target: view.ScrollBar.vertical
            }

            Layout.fillHeight: true

            ScrollView {
                id: view
                anchors.fill: parent
                ListView {
                    model: 20

                    // focus: true

                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem)

                    activeFocusOnTab: true

                    spacing: 16

                    delegate: Button {
                        required property int index
                        text: "Item " + index
                    }
                }
            }
        }
        FocusScope {
            id: discoverTab
            readonly property string title: "Flickable"
            GP.ScrollHandler {
                target: flick
                usePercentageBased: true
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
                    height: 20000
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
        FocusScope {
            id: tabThree
            readonly property string title: "Vertical page"
            GP.ScrollHandler {
                target: view3.ScrollBar.vertical
            }

            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: view3
                anchors.fill: parent
                contentWidth: availableWidth

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                ColumnLayout {

                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem)

                    width: view3.availableWidth

                    Button {
                        focus: true
                        text: "button1"
                    }
                    Button {
                        text: "button2"
                    }
                    Label {
                        text: ["Controller labels", GP.Labels.south, GP.Labels.east, GP.Labels.west, GP.Labels.north].join(', ')
                    }
                    Repeater {
                        model: 100
                        delegate: Button {
                            required property int index
                            text: `Button ${index + 3}`
                            enabled: index % 5 !== 0
                        }
                    }
                }
            }
        }
        FocusScope {
            id: tabFour
            readonly property string title: "Horizontal page"
            GP.ScrollHandler {
                target: view4.ScrollBar.horizontal
            }

            Layout.fillHeight: true
            Layout.fillWidth: true

            ScrollView {
                id: view4
                anchors.fill: parent
                contentHeight: availableHeight

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                RowLayout {
                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem)

                    height: view4.availableHeight

                    Button {
                        focus: true
                        text: "button1"
                    }
                    Button {
                        text: "button2"
                    }
                    Label {
                        text: ["Controller labels", GP.Labels.south, GP.Labels.east, GP.Labels.west, GP.Labels.north].join(', ')
                    }
                    Repeater {
                        model: 100
                        delegate: Button {
                            required property int index
                            text: `Button ${index + 3}`
                            enabled: index % 5 !== 0
                        }
                    }
                }
            }
        }
        FocusScope {
            id: tab5
            readonly property string title: "Advanced page"
            GP.ScrollHandler {
                target: view5.ScrollBar.vertical
            }

            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: view5
                anchors.fill: parent
                contentWidth: availableWidth

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                ColumnLayout {
                    id: col5

                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem, col5)

                    Button {
                        // focus: true
                        text: "button1"
                    }
                    Button {
                        text: "button2"
                    }
                    Label {
                        text: ["Controller labels", GP.Labels.south, GP.Labels.east, GP.Labels.west, GP.Labels.north].join(', ')
                    }
                    ListView {
                        activeFocusOnTab: true
                        keyNavigationEnabled: false
                        reuseItems: true

                        clip: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160

                        model: 50
                        spacing: 8

                        delegate: Button {
                            focusPolicy: Qt.NoTabFocus

                            required property int index
                            text: "Item " + index
                        }
                    }
                    Button {
                        text: "button3"
                    }
                    Button {
                        text: "button4"
                    }
                }
            }
        }
    }
}
