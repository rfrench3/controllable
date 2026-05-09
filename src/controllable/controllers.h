// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QQuickItem>
#include <QString>
#include <QTimer>
#include <SDL3/SDL.h>
#include <cstdint>
#include <map>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

#define POLLING_RATE 16 // ~60FPS

#define NO_CONTROLLER 0

using std::map;

struct ControllerLabels {
    Q_GADGET
    // Expose members as properties to QML
    Q_PROPERTY(QString a MEMBER m_a CONSTANT)
    Q_PROPERTY(QString b MEMBER m_b CONSTANT)
    Q_PROPERTY(QString x MEMBER m_x CONSTANT)
    Q_PROPERTY(QString y MEMBER m_y CONSTANT)
    Q_PROPERTY(QString space MEMBER m_S CONSTANT)
    Q_PROPERTY(QString space_large MEMBER m_S_big CONSTANT)

    // The correct glyphs are initialized by Gamepad::changeGamepadLabels()
    // The a-b-x-y names here follow the Xbox layout
    QString m_a;
    QString m_b;
    QString m_x;
    QString m_y;
    QString m_S;
    QString m_S_big; // m_S times three
};

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

// If a double is returned for an axis value, it ranges from -1 to 1.
class Gamepad : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int pollingRate READ getPollingRate CONSTANT)
    Q_PROPERTY(double deadzone READ getDeadzone CONSTANT)

    Q_PROPERTY(double leftX READ getLeftX NOTIFY leftXChanged)
    Q_PROPERTY(double leftY READ getLeftY NOTIFY leftYChanged)
    Q_PROPERTY(double rightX READ getRightX NOTIFY rightXChanged)
    Q_PROPERTY(double rightY READ getRightY NOTIFY rightYChanged)
    Q_PROPERTY(double leftTrigger READ getLeftTrigger NOTIFY leftTriggerChanged)
    Q_PROPERTY(double rightTrigger READ getRightTrigger NOTIFY rightTriggerChanged)

    double getAxisValue(SDL_GamepadAxis axis) const;

    // wrapper for the signals of each "get axis"
    void axisValueChanged(SDL_GamepadAxis axis);

public:
    double getLeftX() const
    {
        return getAxisValue(SDL_GAMEPAD_AXIS_LEFTX);
    }
    Q_SIGNAL void leftXChanged();
    double getLeftY() const
    {
        return getAxisValue(SDL_GAMEPAD_AXIS_LEFTY);
    }
    Q_SIGNAL void leftYChanged();
    double getRightX() const
    {
        return getAxisValue(SDL_GAMEPAD_AXIS_RIGHTX);
    }
    Q_SIGNAL void rightXChanged();
    double getRightY() const
    {
        return getAxisValue(SDL_GAMEPAD_AXIS_RIGHTY);
    }
    Q_SIGNAL void rightYChanged();
    double getLeftTrigger() const
    {
        return getAxisValue(SDL_GAMEPAD_AXIS_LEFT_TRIGGER);
    }
    Q_SIGNAL void leftTriggerChanged();
    double getRightTrigger() const
    {
        return getAxisValue(SDL_GAMEPAD_AXIS_RIGHT_TRIGGER);
    }
    Q_SIGNAL void rightTriggerChanged();

    void pollSDL();
    QTimer *m_timer;

    // m_focusedJoystick ensures the glyphs don't re-update on every input from one controller
    SDL_JoystickID m_focusedJoystick = NO_CONTROLLER;

    void setFocusedController(SDL_JoystickID which);
    void handleGamepadAdded(SDL_JoystickID which);
    void handleGamepadRemoved(SDL_JoystickID which);
    void handleAxisMotion(SDL_Event &event);
    void axisEmulateDpad(const int16_t &axisPrev, const int16_t &axisNow);

    const double DEADZONE = 0.2;

public:
    Gamepad(QObject *parent = nullptr);

    int getPollingRate() const
    {
        return POLLING_RATE;
    }

    double getDeadzone() const
    {
        return DEADZONE;
    }

    Q_INVOKABLE void setPollController(bool windowActiveState);
    Q_SIGNAL void buttonPressed(uint8_t button, bool button_down);
    Q_SIGNAL void gamepadPresentChanged();
    Q_SIGNAL void labelsChanged();

    Q_INVOKABLE void sendButtonPressed(QQuickItem *item, Qt::Key key);
    Q_INVOKABLE void sendButtonReleased(QQuickItem *item, Qt::Key key);

    Q_INVOKABLE void sendMousePressed(QQuickItem *item);
    Q_INVOKABLE void sendMouseReleased(QQuickItem *item);
};
