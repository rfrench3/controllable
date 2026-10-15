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

    // targetScrollbar is an Item cast to ScrollBar to avoid linter issues of "QQuickScrollBar is not ScrollBar"

    // When given a scroll bar, the right stick will smoothly scroll through it
    property Item targetScrollbar: null as ScrollBar

    function pressAction(buttonId: int): void {
        const action = root.__actionsPressed[buttonId];
        if (typeof action === "function")
            action();
    }

    readonly property var __actionsPressed: ({
            [SDL.SOUTH]: function (): void {
                __mouseEvent(true);
            },
            [SDL.DPAD_UP]: function (): void {
                const item = root.Window.window.activeFocusItem;
                const itemUp = root.__nextItemInScope(item, false);
                itemUp.forceActiveFocus(Qt.TabFocusReason);
            },
            [SDL.DPAD_DOWN]: function (): void {
                const item = root.Window.window.activeFocusItem;
                const itemDown = root.__nextItemInScope(item, true);
                itemDown.forceActiveFocus(Qt.TabFocusReason);
            }
        })

    Connections {
        target: Gamepad

        enabled: root.active

        function onButtonPressed(buttonId: int): void {
            root.pressAction(buttonId);
        }

        function onButtonReleased(buttonId: int): void {
            if (buttonId == SDL.SOUTH)
                root.__mouseEvent(false);
        }
    }

    ScrollHandler {
        target: root.targetScrollbar
        active: root.active
    }

    function __mouseEvent(button_down: bool, item = root.Window.window.activeFocusItem): void {
        if (button_down == true) {
            Gamepad.sendMousePressed(item);
            // console.log("mouse down");
        } else {
            Gamepad.sendMouseReleased(item);
            // console.log("mouse up");
        }
    }

    function __keyEvent(button_down: bool, key: int): void {
        let item = root.Window.window.activeFocusItem;
        if (button_down == true) {
            // console.log("button down");
            Gamepad.sendButtonPressed(item, key);
        } else {
            // console.log("button up");
            Gamepad.sendButtonReleased(item, key);
        }
    }

    function __descendantOfParent(item: QtObject): bool {
        let cursor = item;
        while (cursor) {
            if (cursor === root.parent)
                return true;
            cursor = cursor.parent;
        }
        return false;
    }

    function __nextItemInScope(item: Item, forward: bool): Item {
        if (!item)
            return null;

        let next = item.nextItemInFocusChain(forward);

        for (let i = 0; i < 512; i++) {
            if (__descendantOfParent(next))
                return next;
            next = next.nextItemInFocusChain(forward);
        }

        console.log("Next item in focus scope not found after 512 tries, returning original item.");

        return item;
    }
}
