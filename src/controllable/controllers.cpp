// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "controllers.h"
#include "labels.h"
#include <QCoreApplication>
#include <QGuiApplication>
#include <QKeyEvent>
#include <QQuickWindow>
#include <SDL3/SDL_gamepad.h>
#include <qcoreapplication.h>
#include <qguiapplication.h>
#include <qnamespace.h>

Gamepad::Gamepad(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
{
    // Focus is manually handled to work with Qt
    SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");

    if (!SDL_Init(SDL_INIT_GAMEPAD)) {
        qWarning() << "SDL_Init Error:" << SDL_GetError();
        return;
    }

    connect(m_timer, &QTimer::timeout, this, QOverload<>::of(&Gamepad::pollSDL));
    m_timer->start(POLLING_RATE);
    qDebug() << "Gamepad initialized.";

    connect(qGuiApp, &QGuiApplication::applicationStateChanged, [this](Qt::ApplicationState state) {
        setPollController(state == Qt::ApplicationActive);
    });
}

double Gamepad::getAxisValue(SDL_GamepadAxis axis) const
{
    if (!polling_active)
        return 0;

    // If the gamepad or axis is invalid, this returns 0
    SDL_Gamepad *gamepad = SDL_GetGamepadFromID(m_focusedJoystick);

    double value = static_cast<double>(SDL_GetGamepadAxis(gamepad, axis)) / static_cast<double>(SDL_MAX_SINT16);

    if (std::abs(value) < DEADZONE)
        return 0;

    return SDL_clamp(value, -1, 1);
}

void Gamepad::setPollController(bool windowActive)
{
    if (windowActive == true) {
        // Window focused: Starting controller polling

        // Clear any events that occurred when unfocused,
        // except for controller connections/disconnections
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_GAMEPAD_ADDED)
                handleGamepadAdded(event.gdevice.which);
            else if (event.type == SDL_EVENT_GAMEPAD_REMOVED)
                handleGamepadRemoved(event.gdevice.which);
        }
        m_timer->start(POLLING_RATE);
        polling_active = true;
    } else {
        // Window unfocused: Pausing controller polling
        m_timer->stop();
        polling_active = false;
    }
}

void Gamepad::pollSDL()
{
    SDL_Event event;
    processRepeats();
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
        case SDL_EVENT_GAMEPAD_BUTTON_DOWN:
            Q_EMIT buttonEvent(event.gbutton.button, true);
            setFocusedController(event.gbutton.which);
            updateRepeatState(event.gbutton.which, event.gbutton.button, true);
            break;

        case SDL_EVENT_GAMEPAD_BUTTON_UP:
            Q_EMIT buttonEvent(event.gbutton.button, false);
            setFocusedController(event.gbutton.which);
            updateRepeatState(event.gbutton.which, event.gbutton.button, false);
            break;

        case SDL_EVENT_GAMEPAD_AXIS_MOTION:
            axisValueChanged(static_cast<SDL_GamepadAxis>(event.gaxis.axis));
            setFocusedController(event.gaxis.which);
            break;

        case SDL_EVENT_GAMEPAD_ADDED:
            handleGamepadAdded(event.gdevice.which);
            setFocusedController(event.gdevice.which);
            break;

        case SDL_EVENT_GAMEPAD_REMOVED:
            handleGamepadRemoved(event.gdevice.which);
            setFocusedController(NO_CONTROLLER);
            break;
        }
    }
}

// Updates gamepad labels when the focused controller changes
void Gamepad::setFocusedController(SDL_JoystickID which)
{
    if (labels())
        labels()->changeLabels(which);
    m_focusedJoystick = which;
}

void Gamepad::axisValueChanged(SDL_GamepadAxis axis)
{
    switch (axis) {
    case SDL_GAMEPAD_AXIS_LEFTX:
        Q_EMIT leftXChanged();
        break;

    case SDL_GAMEPAD_AXIS_LEFTY:
        axisEmulateDpad(leftY_prev, getLeftY());
        leftY_prev = getLeftY();
        Q_EMIT leftYChanged();
        break;

    case SDL_GAMEPAD_AXIS_RIGHTX:
        Q_EMIT rightXChanged();
        break;

    case SDL_GAMEPAD_AXIS_RIGHTY:
        Q_EMIT rightYChanged();
        break;

    case SDL_GAMEPAD_AXIS_LEFT_TRIGGER:
        Q_EMIT leftTriggerChanged();
        break;

    case SDL_GAMEPAD_AXIS_RIGHT_TRIGGER:
        Q_EMIT rightTriggerChanged();
        break;

    default:
        break;
    }
}

void Gamepad::handleGamepadAdded(SDL_JoystickID which)
{
    qDebug() << "New Device Detected! ID:" << which;

    SDL_Gamepad *newGamepad = SDL_OpenGamepad(which);

    if (newGamepad) {
        qDebug() << "Gamepad Opened Name:" << SDL_GetGamepadName(newGamepad);
    } else {
        qWarning() << "Could not open gamepad!" << SDL_GetError();
    }
}

void Gamepad::handleGamepadRemoved(SDL_JoystickID which)
{
    if (SDL_GetGamepadFromID(which)) {
        qDebug() << "Device Removed ID:" << which;
        SDL_CloseGamepad(SDL_GetGamepadFromID(which));
    }
}

void Gamepad::axisEmulateDpad(const int16_t &axisPrev, const int16_t &axisNow)
{
    // If the state relative to the controller deadzone has changed, emulate the appropriate Dpad input

    // x < -DEADZONE
    if (axisNow < -DEADZONE && !(axisPrev < -DEADZONE)) {
        Q_EMIT buttonEvent(SDL_GAMEPAD_BUTTON_DPAD_UP, true);
        updateRepeatState(m_focusedJoystick, SDL_GAMEPAD_BUTTON_DPAD_UP, true);
    }
    if (!(axisNow < -DEADZONE) && axisPrev < -DEADZONE) {
        Q_EMIT buttonEvent(SDL_GAMEPAD_BUTTON_DPAD_UP, false);
        updateRepeatState(m_focusedJoystick, SDL_GAMEPAD_BUTTON_DPAD_UP, false);
    }

    // x > DEADZONE
    if (axisNow > DEADZONE && !(axisPrev > DEADZONE)) {
        Q_EMIT buttonEvent(SDL_GAMEPAD_BUTTON_DPAD_DOWN, true);
        updateRepeatState(m_focusedJoystick, SDL_GAMEPAD_BUTTON_DPAD_DOWN, true);
    }
    if (!(axisNow > DEADZONE) && axisPrev > DEADZONE) {
        Q_EMIT buttonEvent(SDL_GAMEPAD_BUTTON_DPAD_DOWN, false);
        updateRepeatState(m_focusedJoystick, SDL_GAMEPAD_BUTTON_DPAD_DOWN, false);
    }
}

void Gamepad::processRepeats()
{
    auto now = QDateTime::currentMSecsSinceEpoch();

    for (auto &pair : m_repeatStates) {
        auto &state = pair.second;

        if (!(state.upHeld ^ state.downHeld))
            break;

        if (state.upHeld && now >= state.upNextFire) {
            Q_EMIT buttonEvent(SDL_GAMEPAD_BUTTON_DPAD_UP, true);
            state.upNextFire = now + KEY_REPEAT_RATE;
        }
        if (state.downHeld && now >= state.downNextFire) {
            Q_EMIT buttonEvent(SDL_GAMEPAD_BUTTON_DPAD_DOWN, true);
            state.downNextFire = now + KEY_REPEAT_RATE;
        }
    }
}

void Gamepad::updateRepeatState(SDL_JoystickID id, uint8_t btn, bool pressed)
{
    if (btn != SDL_GAMEPAD_BUTTON_DPAD_UP && btn != SDL_GAMEPAD_BUTTON_DPAD_DOWN)
        return;

    auto &state = m_repeatStates[id];
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    const qint64 initialDelayMs = KEY_REPEAT_DELAY;

    if (btn == SDL_GAMEPAD_BUTTON_DPAD_UP) {
        if (pressed) {
            state.upHeld = true;
            state.upNextFire = now + initialDelayMs;
        } else {
            state.upHeld = false;
            state.upNextFire = 0;
        }
    } else { // DPAD_DOWN
        if (pressed) {
            state.downHeld = true;
            state.downNextFire = now + initialDelayMs;
        } else {
            state.downHeld = false;
            state.downNextFire = 0;
        }
    }
}

namespace InputEmulator
{
void sendButtonPressed(QQuickItem *item, Qt::Key key)
{
    if (!item)
        return;

    QKeyEvent keyEvent(QEvent::KeyPress, key, Qt::NoModifier);
    QCoreApplication::sendEvent(item, &keyEvent);
}

void sendButtonReleased(QQuickItem *item, Qt::Key key)
{
    if (!item)
        return;

    QKeyEvent keyEvent(QEvent::KeyRelease, key, Qt::NoModifier);
    QCoreApplication::sendEvent(item, &keyEvent);
}

void sendMousePressed(QQuickItem *item)
{
    if (!item)
        return;

    qreal pos_x = item->x();
    qreal pos_y = item->y();

    QPointF point = QPointF(pos_x, pos_y);
    QMouseEvent event =
        QMouseEvent(QEvent::MouseButtonPress, QPointF(), point, Qt::MouseButton::LeftButton, Qt::MouseButton::LeftButton, Qt::KeyboardModifier::NoModifier);
    QCoreApplication::sendEvent(item, &event);
}

void sendMouseReleased(QQuickItem *item)
{
    if (!item)
        return;

    qreal pos_x = item->x();
    qreal pos_y = item->y();

    QPointF point = QPointF(pos_x, pos_y);
    QMouseEvent event =
        QMouseEvent(QEvent::MouseButtonRelease, QPointF(), point, Qt::MouseButton::LeftButton, Qt::MouseButton::NoButton, Qt::KeyboardModifier::NoModifier);
    QCoreApplication::sendEvent(item, &event);
}

// FIXME: Not reliable:
// - if the center of item is under another object, the above object gets scrolled
// - if the center of item is not visible, the scroll fails
void sendScrollEvent(QQuickItem *item, int strength)
{
    if (!item || !item->window())
        return;

    // Use item center in scene coords
    QPointF scenePos = item->mapToScene(QPointF(item->width() / 2, item->height() / 2));
    QPointF globalPos = item->window()->mapToGlobal(scenePos.toPoint());

    QWheelEvent event(scenePos, // position in scene
                      globalPos, // global position
                      QPoint(0, -strength), // pixel delta
                      QPoint(0, 0), // angle delta
                      Qt::NoButton,
                      Qt::NoModifier,
                      Qt::ScrollUpdate,
                      false,
                      Qt::MouseEventSynthesizedByApplication);

    QWheelEvent eventBegin(scenePos, // position in scene
                           globalPos, // global position
                           QPoint(0, -strength), // pixel delta
                           QPoint(0, 0), // angle delta
                           Qt::NoButton,
                           Qt::NoModifier,
                           Qt::ScrollBegin,
                           false,
                           Qt::MouseEventSynthesizedByApplication);

    QWheelEvent eventEnd(scenePos, // position in scene
                         globalPos, // global position
                         QPoint(0, -strength), // pixel delta
                         QPoint(0, 0), // angle delta
                         Qt::NoButton,
                         Qt::NoModifier,
                         Qt::ScrollEnd,
                         false,
                         Qt::MouseEventSynthesizedByApplication);

    QCoreApplication::sendEvent(item->window(), &eventBegin);
    QCoreApplication::sendEvent(item->window(), &event);
    QCoreApplication::sendEvent(item->window(), &eventEnd);
}
}
