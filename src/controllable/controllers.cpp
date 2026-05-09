// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "controllers.h"
#include <KLocalizedString>
#include <QCoreApplication>
#include <QGuiApplication>
#include <QKeyEvent>
#include <QQuickWindow>
#include <qcoreapplication.h>

using namespace Qt::Literals::StringLiterals;

Labels *Labels::m_instance = nullptr;

void Labels::changeLabels(SDL_JoystickID which)
{
    // Only change labels when necessary
    if (which == m_focusedJoystick)
        return;
    else
        m_focusedJoystick = which;

    SDL_Gamepad *temp = SDL_GetGamepadFromID(which);

    if (temp) {
        south = getLabelForButton(temp, SDL_GAMEPAD_BUTTON_SOUTH);
        east = getLabelForButton(temp, SDL_GAMEPAD_BUTTON_EAST);
        west = getLabelForButton(temp, SDL_GAMEPAD_BUTTON_WEST);
        north = getLabelForButton(temp, SDL_GAMEPAD_BUTTON_NORTH);
        spacer = u" "_s;
        spacer_large = u"   "_s;
    } else {
        south = u""_s;
        east = u""_s;
        west = u""_s;
        north = u""_s;
        spacer = u""_s;
        spacer_large = u""_s;
    }

    Q_EMIT labelsChanged();
}

QString Labels::getLabelForButton(SDL_Gamepad *gamepad, SDL_GamepadButton button)
{
    // Ask SDL what is written on this physical button
    SDL_GamepadButtonLabel label = SDL_GetGamepadButtonLabel(gamepad, button);

    switch (label) {
    case SDL_GAMEPAD_BUTTON_LABEL_A:
        return u"(A)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_B:
        return u"(B)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_X:
        return u"(X)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_Y:
        return u"(Y)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_CROSS:
        return u"(✖)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_CIRCLE:
        return u"(🞇)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_SQUARE:
        return u"(🞑)"_s;
    case SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE:
        return u"(🛆)"_s;
    default:
        return u"(?)"_s; // Unknown
    }
}

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
    } else {
        // Window unfocused: Pausing controller polling
        m_timer->stop();
    }
}

void Gamepad::pollSDL()
{
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
        case SDL_EVENT_GAMEPAD_BUTTON_DOWN:
            Q_EMIT buttonPressed(event.gbutton.button, true);
            setFocusedController(event.gbutton.which);
            break;

        case SDL_EVENT_GAMEPAD_BUTTON_UP:
            Q_EMIT buttonPressed(event.gbutton.button, false);
            setFocusedController(event.gbutton.which);
            break;

        case SDL_EVENT_GAMEPAD_AXIS_MOTION:
            handleAxisMotion(event);
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
    labels()->changeLabels(which);
    m_focusedJoystick = which;
}

void Gamepad::handleAxisMotion(SDL_Event &event)
{
    if (event.gaxis.axis == SDL_GAMEPAD_AXIS_INVALID || event.gaxis.axis == SDL_GAMEPAD_AXIS_COUNT) {
        qWarning() << "Invalid axis event ignored";
        return;
    }

    axisValueChanged(static_cast<SDL_GamepadAxis>(event.gaxis.axis));
}

void Gamepad::axisValueChanged(SDL_GamepadAxis axis)
{
    switch (axis) {
    case SDL_GAMEPAD_AXIS_LEFTX:
        Q_EMIT leftXChanged();
        break;

    case SDL_GAMEPAD_AXIS_LEFTY:
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

void Gamepad::axisEmulateDpad(const int16_t &axisPrev, const int16_t &axisNow)
{
    // If the state relative to the controller deadzone has changed, emulate the appropriate Dpad input

    // x < -DEADZONE
    if (axisNow < -DEADZONE && !(axisPrev < -DEADZONE)) {
        Q_EMIT buttonPressed(SDL_GAMEPAD_BUTTON_DPAD_UP, true);
    }
    if (!(axisNow < -DEADZONE) && axisPrev < -DEADZONE) {
        Q_EMIT buttonPressed(SDL_GAMEPAD_BUTTON_DPAD_UP, false);
    }

    // x > DEADZONE
    if (axisNow > DEADZONE && !(axisPrev > DEADZONE)) {
        Q_EMIT buttonPressed(SDL_GAMEPAD_BUTTON_DPAD_DOWN, true);
    }
    if (!(axisNow > DEADZONE) && axisPrev > DEADZONE) {
        Q_EMIT buttonPressed(SDL_GAMEPAD_BUTTON_DPAD_DOWN, false);
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

void Gamepad::sendButtonPressed(QQuickItem *item, Qt::Key key)
{
    QKeyEvent keyEvent(QEvent::KeyPress, key, Qt::NoModifier, QString(), false, 1);
    QCoreApplication::sendEvent(item, &keyEvent);
}

void Gamepad::sendButtonReleased(QQuickItem *item, Qt::Key key)
{
    if (key == Qt::Key::Key_Tab || key == Qt::Key::Key_Up || key == Qt::Key::Key_Down)
        return;
    QKeyEvent keyEvent(QEvent::KeyPress, key, Qt::NoModifier, QString(), false, 1);
    QCoreApplication::sendEvent(item, &keyEvent);
}

void Gamepad::sendMousePressed(QQuickItem *item)
{
    qreal pos_x = item->x();
    qreal pos_y = item->y();

    QPointF point = QPointF(pos_x, pos_y);
    QMouseEvent event =
        QMouseEvent(QEvent::MouseButtonPress, QPointF(), point, Qt::MouseButton::LeftButton, Qt::MouseButton::LeftButton, Qt::KeyboardModifier::NoModifier);
    QCoreApplication::sendEvent(item, &event);
}

void Gamepad::sendMouseReleased(QQuickItem *item)
{
    qreal pos_x = item->x();
    qreal pos_y = item->y();

    QPointF point = QPointF(pos_x, pos_y);
    QMouseEvent event =
        QMouseEvent(QEvent::MouseButtonRelease, QPointF(), point, Qt::MouseButton::LeftButton, Qt::MouseButton::NoButton, Qt::KeyboardModifier::NoModifier);
    QCoreApplication::sendEvent(item, &event);
}
