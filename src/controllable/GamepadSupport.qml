// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import io.github.rfrench3.controllable

// Place as a child of the application window
Item {
    id: root

    // When there is no active item to target, send inputs here
    property Item fallbackTarget: Window.activeFocusItem

    function __onButtonEvent(button: int, pressed: bool): void {
        let key = 0;

        switch (button) {
        case SDL.NORTH:
            key = GamepadKeys.TERTIARY;
            break;
        case SDL.SOUTH:
            key = GamepadKeys.PRIMARY;
            break;
        case SDL.EAST:
            key = GamepadKeys.BACK;
            break;
        case SDL.WEST:
            key = GamepadKeys.SECONDARY;
            break;
        case SDL.DPAD_UP:
            key = Qt.Key_Up;
            break;
        case SDL.DPAD_DOWN:
            key = Qt.Key_Down;
            break;
        case SDL.DPAD_LEFT:
            key = Qt.Key_Left;
            break;
        case SDL.DPAD_RIGHT:
            key = Qt.Key_Right;
            break;
        case SDL.LEFT_SHOULDER:
            key = GamepadKeys.LEFT_BUMPER;
            break;
        case SDL.RIGHT_SHOULDER:
            key = GamepadKeys.RIGHT_BUMPER;
            break;
        }

        if (!key)
            return;

        const target = Window.activeFocusItem ? Window.activeFocusItem : fallbackTarget;

        if (pressed)
            KeyEmulator.sendButtonPressed(target, key);
        else
            KeyEmulator.sendButtonReleased(target, key);
    }

    property Connections _conn: Connections {
        target: Gamepad
        enabled: root.enabled

        function onButtonPressed(button: int): void {
            root.__onButtonEvent(button, true);
        }

        function onButtonReleased(button: int): void {
            root.__onButtonEvent(button, false);
        }
    }
}
