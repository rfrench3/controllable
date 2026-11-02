// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Controls
import io.github.rfrench3.controllable

Item {
    id: root

    // Move a fixed fraction of the content length per tick instead of a
    // fixed pixel distance, so scroll speed scales with content size
    property bool usePercentageBased: false

    // Must be either Flickable or ScrollBar
    required property Item target

    property bool active: visible
    property real sensitivity: 1

    Timer {
        id: timer

        // ramp-up the pixel-based scrolling speed over time
        property double startTime: 0

        onRunningChanged: {
            if (running)
                startTime = Date.now();
            else
                startTime = 0;
        }

        readonly property bool isValid: root.target instanceof Flickable || root.target instanceof ScrollBar
        readonly property ScrollBar scrollBar: root.target as ScrollBar
        readonly property Flickable flickable: root.target as Flickable
        readonly property real pixelStep: root.sensitivity * 16
        readonly property bool scrollbarVertical: scrollBar ? scrollBar.vertical : true

        interval: Gamepad.pollingRate
        running: root.active && ((Math.abs(Gamepad.rightY) > Gamepad.deadzone) || (Math.abs(Gamepad.rightX) > Gamepad.deadzone))
        repeat: true
        onTriggered: {
            function clamp(val: double, min: double, max: double): double {
                return Math.min(Math.max(val, min), max);
            }

            // How many viewport-lengths of content there are along an axis (>= 1)
            function contentRatio(vertical: bool): real {
                if (root.target instanceof ScrollBar) {
                    // ScrollBar.size is viewport / content, so invert it
                    if (scrollBar.size <= 0)
                        return 1;
                    return Math.max(1, 1 / scrollBar.size);
                } else if (root.target instanceof Flickable) {
                    const content = vertical ? flickable.contentHeight : flickable.contentWidth;
                    const viewport = vertical ? flickable.height : flickable.width;
                    if (viewport <= 0)
                        return 1;
                    return Math.max(1, content / viewport);
                }
                return 1;
            }

            // After startDelay, ramp up smoothly from 1. Larger content ramps up faster.
            function calculateRampUp(ratio: real): real {
                const runtime = Date.now() - startTime;
                const startDelay = 2000;
                const speed = 4000;

                if (runtime < startDelay)
                    return 1;

                // sqrt keeps very large content from ramping up uncontrollably
                const sizeFactor = Math.min(Math.sqrt(ratio), 1);

                return 1 + ((runtime - startDelay) / speed) * sizeFactor;
            }

            if (root.target instanceof ScrollBar) {
                if (scrollBar.size >= 1)
                    return;

                const deltaY = (Math.abs(Gamepad.rightY) > Gamepad.deadzone) ? Gamepad.rightY * calculateRampUp(contentRatio(true)) : 0;
                const deltaX = (Math.abs(Gamepad.rightX) > Gamepad.deadzone) ? Gamepad.rightX * calculateRampUp(contentRatio(false)) : 0;

                const viewportLength = scrollbarVertical ? scrollBar.height : scrollBar.width;
                if (viewportLength <= 0)
                    return;

                const pixelsToPosition = scrollBar.size / viewportLength;
                const delta = scrollbarVertical ? deltaY : deltaX;
                const step = root.usePercentageBased ? delta * root.sensitivity / 64 : delta * pixelStep * pixelsToPosition;

                const new_pos = scrollBar.position + step;
                const min_pos = 0;
                const max_pos = 1 - scrollBar.size;

                scrollBar.position = clamp(new_pos, min_pos, max_pos);
            } else if (root.target instanceof Flickable) {
                const deltaY = (Math.abs(Gamepad.rightY) > Gamepad.deadzone) ? Gamepad.rightY : 0;
                const deltaX = (Math.abs(Gamepad.rightX) > Gamepad.deadzone) ? Gamepad.rightX : 0;

                if (flickable.contentHeight > flickable.height) {
                    const min_pos = flickable.originY;
                    const max_pos = min_pos + flickable.contentHeight - flickable.height;
                    const step = root.usePercentageBased ? deltaY * root.sensitivity / 64 * flickable.contentHeight : deltaY * pixelStep;
                    const new_pos = flickable.contentY + step;

                    flickable.contentY = clamp(new_pos, min_pos, max_pos);
                }
                if (flickable.contentWidth > flickable.width) {
                    const min_pos = flickable.originX;
                    const max_pos = min_pos + flickable.contentWidth - flickable.width;
                    const step = root.usePercentageBased ? deltaX * root.sensitivity / 64 * flickable.contentWidth : deltaX * pixelStep;
                    const new_pos = flickable.contentX + step;

                    flickable.contentX = clamp(new_pos, min_pos, max_pos);
                }
            }
        }
    }

    Component.onCompleted: {
        if (!timer.isValid)
            console.log("Target is not a Scrollbar or flickable.");
    }
}
