// SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "labels.h"
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
