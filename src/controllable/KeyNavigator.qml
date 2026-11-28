// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as KG
import io.github.rfrench3.controllable

Item {
    id: root

    readonly property int scrollMargin: KG.Units.gridUnit
    readonly property int scrollDuration: KG.Units.longDuration
    property var _activeAnims: new Map()

    Component {
        id: scrollAnimComponent
        ParallelAnimation {
            id: anim
            property Flickable targetFlickable
            property real targetX
            property real targetY

            NumberAnimation {
                target: anim.targetFlickable
                property: "contentX"
                to: anim.targetX
                duration: root.scrollDuration
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: anim.targetFlickable
                property: "contentY"
                to: anim.targetY
                duration: root.scrollDuration
                easing.type: Easing.OutCubic
            }

            onFinished: {
                if (root._activeAnims.get(targetFlickable) === anim)
                    root._activeAnims.delete(targetFlickable);
                anim.destroy();
            }
        }
    }

    function navigateEvent(event: KeyEvent, fromItem: Item): bool {
        if (fromItem === null || event === null)
            return false;

        const res = navigate(event.key, fromItem);
        event.accepted = res;
        return res;
    }

    function navigate(direction: int, fromItem: Item): bool {
        if (fromItem === null)
            return false;

        const prevItem = fromItem.nextItemInFocusChain(false);
        const nextItem = fromItem.nextItemInFocusChain(true);

        let targetItem = null;

        switch (direction) {
        case GamepadKeys.UP:
            targetItem = prevItem;
            targetItem.forceActiveFocus(Qt.BacktabFocusReason);
            break;
        case GamepadKeys.DOWN:
            targetItem = nextItem;
            targetItem.forceActiveFocus(Qt.TabFocusReason);
            break;
        case GamepadKeys.LEFT:
            targetItem = prevItem;
            targetItem.forceActiveFocus(Qt.BacktabFocusReason);
            break;
        case GamepadKeys.RIGHT:
            targetItem = nextItem;
            targetItem.forceActiveFocus(Qt.TabFocusReason);
            break;
        default:
            return false;
        }

        ensureVisible(targetItem);
        return true;
    }

    function ensureVisible(item: Item): void {
        if (item === null)
            return;

        const margin = root.scrollMargin;
        let parent = item.parent;

        while (parent !== null) {
            if (parent instanceof Flickable) {
                const flickable = parent as Flickable;
                const pos = item.mapToItem(flickable.contentItem, 0, 0);

                let targetX = flickable.contentX;
                let targetY = flickable.contentY;

                // Vertical scrolling
                if (flickable.contentHeight > flickable.height) {
                    const maxY = flickable.originY + flickable.contentHeight - flickable.height;

                    if (pos.y - margin < targetY) {
                        targetY = pos.y - margin;
                    } else if (pos.y + item.height + margin > targetY + flickable.height) {
                        targetY = pos.y + item.height + margin - flickable.height;
                    }

                    targetY = Math.max(flickable.originY, Math.min(targetY, maxY));
                }

                // Horizontal scrolling
                if (flickable.contentWidth > flickable.width) {
                    const maxX = flickable.originX + flickable.contentWidth - flickable.width;

                    if (pos.x - margin < targetX) {
                        targetX = pos.x - margin;
                    } else if (pos.x + item.width + margin > targetX + flickable.width) {
                        targetX = pos.x + item.width + margin - flickable.width;
                    }

                    targetX = Math.max(flickable.originX, Math.min(targetX, maxX));
                }

                if (targetX !== flickable.contentX || targetY !== flickable.contentY) {
                    const existing = root._activeAnims.get(flickable);
                    if (existing) {
                        existing.stop();
                        existing.destroy();
                    }

                    const anim = scrollAnimComponent.createObject(root, {
                        targetFlickable: flickable,
                        targetX: targetX,
                        targetY: targetY
                    }) as ParallelAnimation;
                    root._activeAnims.set(flickable, anim);
                    anim.start();
                }
            }

            parent = parent.parent;
        }
    }
}
