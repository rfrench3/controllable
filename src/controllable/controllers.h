// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QQuickItem>
#include <QString>
#include <QTimer>
#include <SDL3/SDL.h>
#include <SDL3/SDL_init.h>
#include <SDL3/SDL_oldnames.h>
#include <cstdint>
#include <map>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

#define POLLING_RATE 16 // ~60FPS

#define NO_CONTROLLER 0

using std::map;

// Emulate keyboard and mouse inputs
namespace InputEmulator
{

void sendButtonPressed(QQuickItem *item, Qt::Key key);
void sendButtonReleased(QQuickItem *item, Qt::Key key);

void sendMousePressed(QQuickItem *item);
void sendMouseReleased(QQuickItem *item);

};

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
    void setPollController(bool windowActiveState);

    void pollSDL();
    QTimer *m_timer;

    // used for left stick DPad emulation
    int16_t leftY_prev;

    // axis value functions
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

public:
    Gamepad(QObject *parent = nullptr);

    ~Gamepad()
    {
        SDL_Quit();
    }

    // keeps track of the controller to read axis values from
    SDL_JoystickID m_focusedJoystick = NO_CONTROLLER;

    void setFocusedController(SDL_JoystickID which);
    void handleGamepadAdded(SDL_JoystickID which);
    void handleGamepadRemoved(SDL_JoystickID which);
    void axisEmulateDpad(const int16_t &axisPrev, const int16_t &axisNow);

    const double DEADZONE = 0.2;

    int getPollingRate() const
    {
        return POLLING_RATE;
    }

    double getDeadzone() const
    {
        return DEADZONE;
    }

    Q_SIGNAL void buttonEvent(uint8_t button, bool pressed);

    Q_INVOKABLE void sendButtonPressed(QQuickItem *item, Qt::Key key)
    {
        InputEmulator::sendButtonPressed(item, key);
    };
    Q_INVOKABLE void sendButtonReleased(QQuickItem *item, Qt::Key key)
    {
        InputEmulator::sendButtonReleased(item, key);
    };

    Q_INVOKABLE void sendMousePressed(QQuickItem *item)
    {
        InputEmulator::sendMousePressed(item);
    };
    Q_INVOKABLE void sendMouseReleased(QQuickItem *item)
    {
        InputEmulator::sendMouseReleased(item);
    };
};
