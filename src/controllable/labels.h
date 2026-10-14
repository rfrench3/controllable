// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "controllers.h"
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QTimer>
#include <SDL3/SDL.h>
#include <map>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qqmlintegration.h>
#include <qtclasshelpermacros.h>
#include <qtmetamacros.h>

using std::map;

class Labels : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_DISABLE_COPY_MOVE(Labels)

    Q_PROPERTY(QString south MEMBER south NOTIFY labelsChanged)
    Q_PROPERTY(QString east MEMBER east NOTIFY labelsChanged)
    Q_PROPERTY(QString west MEMBER west NOTIFY labelsChanged)
    Q_PROPERTY(QString north MEMBER north NOTIFY labelsChanged)
    Q_PROPERTY(QString spacer MEMBER spacer NOTIFY labelsChanged)
    Q_PROPERTY(QString spacer_large MEMBER spacer_large NOTIFY labelsChanged)

    QString south, east, west, north, spacer, spacer_large;
    QString getLabelForButton(SDL_Gamepad *gamepad, SDL_GamepadButton button);

    SDL_JoystickID m_focusedJoystick = NO_CONTROLLER;

    Labels(QObject *parent = nullptr)
        : QObject(parent) {

        };

public:
    static Labels *instance()
    {
        static Labels *s_instance = new Labels();
        return s_instance;
    }

    static Labels *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
    {
        Q_UNUSED(jsEngine);
        Labels *instancePtr = instance();
        qmlEngine->setObjectOwnership(instancePtr, QQmlEngine::CppOwnership);
        return instancePtr;
    }

public:
    Q_SIGNAL void labelsChanged();

    void changeLabels(SDL_JoystickID which);
};

inline Labels *labels = Labels::instance();
