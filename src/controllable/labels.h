// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QQuickItem>
#include <QString>
#include <QTimer>
#include <SDL3/SDL.h>
#include <map>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

#define POLLING_RATE 16 // ~60FPS

#define NO_CONTROLLER 0

using std::map;

class Labels : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString south MEMBER south NOTIFY labelsChanged)
    Q_PROPERTY(QString east MEMBER east NOTIFY labelsChanged)
    Q_PROPERTY(QString west MEMBER west NOTIFY labelsChanged)
    Q_PROPERTY(QString north MEMBER north NOTIFY labelsChanged)
    Q_PROPERTY(QString spacer MEMBER spacer NOTIFY labelsChanged)
    Q_PROPERTY(QString spacer_large MEMBER spacer_large NOTIFY labelsChanged)

    QString south, east, west, north, spacer, spacer_large;
    QString getLabelForButton(SDL_Gamepad *gamepad, SDL_GamepadButton button);
    SDL_JoystickID m_focusedJoystick;

    static Labels *m_instance;

public:
    Labels(QObject *parent = nullptr)
        : QObject(parent)
    {
        m_instance = this;
        m_focusedJoystick = NO_CONTROLLER;
    };

    static Labels *instance()
    {
        return m_instance;
    }

    Q_SIGNAL void labelsChanged();

    void changeLabels(SDL_JoystickID which);
};

inline static Labels *labels()
{
    return Labels::instance();
}
