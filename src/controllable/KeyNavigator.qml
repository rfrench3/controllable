// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import io.github.rfrench3.controllable

// Handles moving between elements within a focus scope using only the arrow keys.
Item {
    id: root

    property int scrollMargin: 18
    property int scrollDuration: 200

    ParallelAnimation {
        id: scrollAnim
        property Flickable targetFlickable
        property real targetX
        property real targetY

        NumberAnimation {
            target: scrollAnim.targetFlickable
            property: "contentX"
            to: scrollAnim.targetX
            duration: root.scrollDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: scrollAnim.targetFlickable
            property: "contentY"
            to: scrollAnim.targetY
            duration: root.scrollDuration
            easing.type: Easing.OutCubic
        }
    }

    function __nextItemInScope(item: Item, parentItem: Item, forward: bool): Item {
        if (!item)
            return null;

        const firstNext = item.nextItemInFocusChain(forward);
        let next = firstNext;

        for (let i = 0; i < 512; i++) {
            if (!next || next === item)
                break;
            if (parentItem === null || QmlUtils.isDescendentOf(next, parentItem))
                return next;

            next = next.nextItemInFocusChain(forward);
            if (next === firstNext)
                break; // Wrapped around the entire focus chain
        }

        console.warn("Next item in focus scope not found, returning original item.");
        return item;
    }

    function navigateEvent(event: KeyEvent, fromItem: Item, maxParent = null): bool {
        if (fromItem === null || event === null)
            return false;

        const res = navigate(event.key, fromItem, maxParent);
        event.accepted = res;
        return res;
    }

    function navigate(direction: int, fromItem: Item, maxParent = null): bool {
        if (fromItem === null)
            return false;

        if (navigateListView(direction, fromItem))
            return true;

        let forward = true;
        let reason = Qt.TabFocusReason;

        // TODO: handle UP/LEFT and DOWN/RIGHT differently depending on the
        // parent container, e.g. ColumnLayout vs RowLayout vs GridLayout
        switch (direction) {
        case GamepadKeys.UP:
        case GamepadKeys.LEFT:
            forward = false;
            reason = Qt.BacktabFocusReason;
            break;
        case GamepadKeys.DOWN:
        case GamepadKeys.RIGHT:
            forward = true;
            reason = Qt.TabFocusReason;
            break;
        default:
            return false;
        }

        const targetItem = __nextItemInScope(fromItem, maxParent, forward);
        if (!targetItem)
            return false;

        targetItem.forceActiveFocus(reason);
        ensureVisible(targetItem);
        return true;
    }

    function navigateListView(direction: int, fromItem: Item): bool {
        // Walk up to find an enclosing ListView and its direct delegate child
        let delegateItem = fromItem as Item;
        let listView = null as ListView;

        while (delegateItem !== null && delegateItem.parent !== null) {
            if (delegateItem.parent.parent instanceof ListView) {
                const candidate = delegateItem.parent.parent as ListView;
                if (delegateItem.parent === candidate.contentItem) {
                    listView = candidate;
                    break;
                }
            }
            delegateItem = delegateItem.parent;
        }

        if (listView === null)
            return false;

        const isVertical = listView.orientation === ListView.Vertical;
        let delta = 0;
        let reason = Qt.TabFocusReason;

        if (isVertical && direction === GamepadKeys.UP) {
            delta = -1;
            reason = Qt.BacktabFocusReason;
        } else if (isVertical && direction === GamepadKeys.DOWN) {
            delta = 1;
        } else if (!isVertical && direction === GamepadKeys.LEFT) {
            delta = -1;
            reason = Qt.BacktabFocusReason;
        } else if (!isVertical && direction === GamepadKeys.RIGHT) {
            delta = 1;
        } else {
            return false;
        }

        // Resolve the delegate's model index from its position inside contentItem
        const currentIdx = listView.indexAt(delegateItem.x + delegateItem.width / 2, delegateItem.y + delegateItem.height / 2);
        const nextIdx = currentIdx + delta;

        if (currentIdx < 0 || nextIdx < 0 || nextIdx >= listView.count)
            return false; // At list boundary: let caller fall back or exit the ListView

        // Grab the next delegate, forcing instantiation if it was culled
        let targetItem = listView.itemAtIndex(nextIdx);
        if (targetItem === null) {
            listView.positionViewAtIndex(nextIdx, ListView.Contain);
            targetItem = listView.itemAtIndex(nextIdx);
        }

        if (targetItem === null)
            return false;

        targetItem.forceActiveFocus(reason);
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
                    scrollAnim.stop();
                    scrollAnim.targetFlickable = flickable;
                    scrollAnim.targetX = targetX;
                    scrollAnim.targetY = targetY;
                    scrollAnim.start();
                    break;
                }
            }

            parent = parent.parent;
        }
    }
}
