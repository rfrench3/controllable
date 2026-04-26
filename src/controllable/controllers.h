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

#define POLLING_RATE 16 // ~60FPS

struct ControllerLabels {
    Q_GADGET
    // Expose members as properties to QML
    Q_PROPERTY(QString a MEMBER m_a CONSTANT)
    Q_PROPERTY(QString b MEMBER m_b CONSTANT)
    Q_PROPERTY(QString x MEMBER m_x CONSTANT)
    Q_PROPERTY(QString y MEMBER m_y CONSTANT)
    Q_PROPERTY(QString space MEMBER m_S CONSTANT)
    Q_PROPERTY(QString space_large MEMBER m_S_big CONSTANT)

public:
    // The correct glyphs are initialized by Gamepad::changeGamepadLabels()
    // The a-b-x-y names here follow the Xbox layout
    QString m_a;
    QString m_b;
    QString m_x;
    QString m_y;
    QString m_S;
    QString m_S_big; // m_S times three
};

class Gamepad : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(ControllerLabels labels READ labels NOTIFY labelsChanged)
    Q_PROPERTY(int16_t rStickMagnitude READ RStickMagnitude NOTIFY RStickMagnitudeChanged)
    Q_PROPERTY(int pollingRate READ getPollingRate CONSTANT)
    Q_PROPERTY(int16_t deadzone READ getDeadzone CONSTANT)

    // range from 0 to 1
    Q_PROPERTY(double leftX READ getLeftX NOTIFY leftXChanged)
    Q_PROPERTY(double leftY READ getLeftY NOTIFY leftYChanged)
    Q_PROPERTY(double rightX READ getRightX NOTIFY rightXChanged)
    Q_PROPERTY(double rightY READ getRightY NOTIFY rightYChanged)
    Q_PROPERTY(double leftTrigger READ getLeftTrigger NOTIFY leftTriggerChanged)
    Q_PROPERTY(double rightTrigger READ getRightTrigger NOTIFY rightTriggerChanged)

    double getLeftX() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.leftx;
        }
        return 0.0;
    }
    Q_SIGNAL void leftXChanged();
    double getLeftY() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.lefty;
        }
        return 0.0;
    }
    Q_SIGNAL void leftYChanged();
    double getRightX() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.rightx;
        }
        return 0.0;
    }
    Q_SIGNAL void rightXChanged();
    double getRightY() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.righty;
        }
        return 0.0;
    }
    Q_SIGNAL void rightYChanged();
    double getLeftTrigger() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.lt;
        }
        return 0.0;
    }
    Q_SIGNAL void leftTriggerChanged();
    double getRightTrigger() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.rt;
        }
        return 0.0;
    }
    Q_SIGNAL void rightTriggerChanged();

    struct GamepadData {
        SDL_Gamepad *gamepad = nullptr;

        double leftx = 0;
        double lefty = 0;
        double rightx = 0;
        double righty = 0;

        double lt = 0;
        double rt = 0;








        // left stick emulates d-pad inputs,
        // range is [x < -DEADZONE, |x| < DEADZONE, x > DEADZONE ]
        int16_t leftStickVertical = 0;
        // int16_t leftStickHorizontal = 0;

        // while (|x| > DEADZONE, scroll proportionally)
        int16_t rightStickVertical = 0;
        // int16_t rightStickHorizontal = 0;
    };

    void pollSDL();
    QTimer *m_timer;

    // m_focusedJoystick ensures the glyphs don't re-update on every input from one controller
    SDL_JoystickID m_focusedJoystick = 0;
    std::map<SDL_JoystickID, GamepadData> m_gamepads;

    void changeGamepadLabels(SDL_JoystickID which);
    QString getLabelForButton(SDL_Gamepad *gamepad, SDL_GamepadButton button);
    void handleGamepadAdded(SDL_JoystickID which);
    void handleGamepadRemoved(SDL_JoystickID which);
    void handleAxisMotion(SDL_Event &event);
    void axisEmulateDpad(const int16_t &axisPrev, const int16_t &axisNow);

    ControllerLabels m_labels;

    const int16_t DEADZONE = 12000; // Range: -32768,32768

public:
    Gamepad(QObject *parent = nullptr);












    ControllerLabels labels() const
    {
        return m_labels;
    }

    int16_t RStickMagnitude() const
    {
        auto it = m_gamepads.find(m_focusedJoystick);
        if (it != m_gamepads.end()) {
            return it->second.rightStickVertical;
        }
        return 0; // Return 0 when no gamepad is connected
    }

    int getPollingRate() const
    {
        return POLLING_RATE;
    }

    int16_t getDeadzone() const
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

    Q_SIGNAL void RStickMagnitudeChanged();
};
