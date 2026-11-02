// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later
#pragma once
#include <QtQuick>
#include <QtTest/QtTest>
#include <qtmetamacros.h>

class KeyEmulator : public QObject
{
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

public:
    bool prepareTarget(QQuickItem *item)
    {
        if (!item || !item->window())
            return false;

        if (!item->hasActiveFocus())
            item->forceActiveFocus();

        return true;
    }

    Q_INVOKABLE void sendButtonPressed(QQuickItem *item, Qt::Key key, Qt::KeyboardModifiers mods = Qt::NoModifier)
    {
        if (prepareTarget(item))
            QTest::keyPress(item->window(), key, mods);
    }

    Q_INVOKABLE void sendButtonReleased(QQuickItem *item, Qt::Key key, Qt::KeyboardModifiers mods = Qt::NoModifier)
    {
        if (prepareTarget(item))
            QTest::keyRelease(item->window(), key, mods);
    }

    Q_INVOKABLE void sendButtonClicked(QQuickItem *item, Qt::Key key, Qt::KeyboardModifiers mods = Qt::NoModifier)
    {
        if (prepareTarget(item))
            QTest::keyClick(item->window(), key, mods);
    }
};
