// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Controls
import io.github.rfrench3.controllable

// Only one of the available components is expected to be used
Item {
    id: root

    //TODO
    property var scrollType: null // percentage based vs distance based

    // Must be either Flickable or ScrollBar
    required property Item target

    // Has no effect when the target is a flickable
    property bool isSbarVertical: true

    property bool active: visible
    property real sensitivity: 1

    readonly property bool __valid: target instanceof Flickable || target instanceof ScrollBar
    readonly property ScrollBar __sbar: target as ScrollBar
    readonly property Flickable __flickable: target as Flickable

    Timer {
        interval: Gamepad.pollingRate
        running: root.active && root.__valid && ((Math.abs(Gamepad.rightY) > Gamepad.deadzone) || (Math.abs(Gamepad.rightX) > Gamepad.deadzone))
        repeat: true
        onTriggered: {
            const clamp = (val, min, max) => Math.min(Math.max(val, min), max);

            const deltaY = (Math.abs(Gamepad.rightY) > Gamepad.deadzone) ? Gamepad.rightY : 0;
            const deltaX = (Math.abs(Gamepad.rightX) > Gamepad.deadzone) ? Gamepad.rightX : 0;

            if (root.target instanceof ScrollBar) {
                const min_pos = 0;
                const max_pos = 1 - root.__sbar.size;

                let new_pos = root.__sbar.position;
                if (root.isSbarVertical)
                    new_pos += deltaY * root.sensitivity / 64;
                else
                    new_pos += deltaX * root.sensitivity / 64;

                root.target.position = clamp(new_pos, min_pos, max_pos);
            } else if (root.target instanceof Flickable) {
                if (root.__flickable.contentHeight > root.target.height) {
                    const min_pos = root.__flickable.originY;
                    const max_pos = min_pos + root.__flickable.contentHeight - root.target.height;
                    const new_pos = root.__flickable.contentY + (deltaY * root.sensitivity * 16);

                    root.target.contentY = clamp(new_pos, min_pos, max_pos);
                }
                if (root.__flickable.contentWidth > root.target.width) {
                    const min_pos = root.__flickable.originX;
                    const max_pos = min_pos + root.__flickable.contentWidth - root.target.width;
                    const new_pos = root.__flickable.contentX + (deltaX * root.sensitivity * 16);

                    root.target.contentX = clamp(new_pos, min_pos, max_pos);
                }
            }
        }
    }

    Component.onCompleted: {
        if (!root.__valid)
            console.log("Invalid data passed to target, scrollHandler will not function.");
    }

    function scrollDistance() {
    }
    function scrollPercent() {
    }
}
