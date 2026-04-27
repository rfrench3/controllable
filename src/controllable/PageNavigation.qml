// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Controls

import io.github.rfrench3.controllable

/**
 * @brief PageNavigation - Adds very basic controller support to a page.
 * 
 * This support is applied by emulating tab navigation.
 * - Dpad/LStick up: shift+tab
 * - Dpad/Lstick down: tab
 * - Xbox A (or equivalent): select highlighted element
 * 
 * @note This is disabled when the global drawer is opened
 */
Item {
    id: root

    property bool active: visible

    // When given a scroll bar, the right stick will smoothly scroll through it
    property ScrollBar targetScrollbar: null

    
    Connections {
        target: Gamepad

        function keyEvent(button_down, key) {
            let item = root.Window.window.activeFocusItem;
            if (button_down == true) {
                // console.log("button down");
                Gamepad.sendButtonPressed(item, key);
            }
            else {
                // console.log("button up");
                Gamepad.sendButtonReleased(item, key);
            }
        }

        function mouseEvent(button_down, item = root.Window.window.activeFocusItem) {
            if (button_down == true) {
                Gamepad.sendMousePressed(item);
                // console.log("mouse down");
            }
            else {
                Gamepad.sendMouseReleased(item);
                // console.log("mouse up");
            }
        }

        /**
         * @brief onButtonPressed - Reimplement this separately from GamepadPageNavigation for custom controller navigation.
         * @param buttonId - SDL3 mapping for controller buttons.
         * @param button_down - true is button is being pressed, false if button is being released.
         */
        function onButtonPressed(buttonId, button_down) {
            if (!active)
                return;

            let item = root.Window.window.activeFocusItem;

            switch (buttonId) {
                case 0: // A
                    mouseEvent(button_down);
                    break;
                
                case 11: // Dpad Up
                    if (!button_down) break;

                    let itemUp = item.nextItemInFocusChain(false);
                    itemUp.forceActiveFocus(Qt.TabFocusReason);
                    break;

                case 12: // Dpad Down
                    if (!button_down) break;

                    let itemDown = item.nextItemInFocusChain(true);
                    itemDown.forceActiveFocus(Qt.TabFocusReason);
                    break;
            }
        }

        function onRightYChanged() {
            // console.log(Gamepad.rightY);
        }
    }

    ScrollHandler {
        scrollBar: root.targetScrollbar 
        active: root.active
    }
}
