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

        Keys.onDownPressed: root.focusCurrentPage()

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
    StackLayout {
        id: root
        anchors.fill: parent
        currentIndex: bar.currentIndex

        function focusCurrentPage(): void {
            const currentTab = root.itemAt(root.currentIndex);
            if (!currentTab)
                return;

            const target = currentTab.nextItemInFocusChain(true);
            if (target && GP.QmlUtils.isDescendentOf(target, currentTab)) {
                target.forceActiveFocus(Qt.TabFocusReason);
                GP.KeyNavigator.ensureVisible(target);
            } else {
                currentTab.forceActiveFocus(Qt.TabFocusReason);
            }
        }

        onCurrentIndexChanged: {
            const active = Window.activeFocusItem as Control;
            if (!active || GP.QmlUtils.isDescendentOf(active, bar))
                return;

            const reason = active.focusReason;
            if (reason === Qt.TabFocusReason || reason === Qt.BacktabFocusReason) {
                focusCurrentPage();
            }
        }

        focus: true
        Keys.onPressed: event => {
            if (event.key === GP.GamepadKeys.BACK)
                Qt.exit(0);

            if (event.key === GP.GamepadKeys.LEFT_BUMPER) {
                bar.decrementCurrentIndex();
                focusCurrentPage();
                event.accepted = true;
                return;
            }

            if (event.key === GP.GamepadKeys.RIGHT_BUMPER) {
                bar.incrementCurrentIndex();
                focusCurrentPage();
                event.accepted = true;
                return;
            }

            if (event.key === GP.GamepadKeys.DOWN) {
                focusCurrentPage();
                event.accepted = true;
                return;
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
                    text: "Keyboard/Gamepad Controls:\n%1, esc: exit app\n%2, [: move 1 tab left\n%3, ]: move 1 tab right\ndpad, arrow keys: navigate up, down, left, right\n%4, spacebar: activate selected item\n%5, x: secondary action\n%6, c: tertiary action\nRight stick, mouse/trackpad/etc: scroll active area" //
                    .arg(GP.Labels.east).arg("(LB)").arg("(RB)").arg(GP.Labels.south).arg(GP.Labels.west).arg(GP.Labels.north)
                }
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

                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem, homeTab)

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

                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem, tabThree)

                    width: view3.availableWidth

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
                    Keys.onPressed: event => GP.KeyNavigator.navigateEvent(event, Window.activeFocusItem, tabFour)

                    height: view4.availableHeight

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
