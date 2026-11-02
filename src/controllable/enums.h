// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

// Register relevant SDL3 enums with Qt

#include <SDL3/SDL_gamepad.h>
#include <qobject.h>
#include <qqml.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

class SDL_GAMEPAD : public QObject
{
    Q_OBJECT;
    QML_NAMED_ELEMENT(SDL);
    QML_SINGLETON;

public:
    enum class BUTTON {
        SOUTH = SDL_GAMEPAD_BUTTON_SOUTH,
        EAST = SDL_GAMEPAD_BUTTON_EAST,
        WEST = SDL_GAMEPAD_BUTTON_WEST,
        NORTH = SDL_GAMEPAD_BUTTON_NORTH,

        DPAD_UP = SDL_GAMEPAD_BUTTON_DPAD_UP,
        DPAD_DOWN = SDL_GAMEPAD_BUTTON_DPAD_DOWN,
        DPAD_LEFT = SDL_GAMEPAD_BUTTON_DPAD_LEFT,
        DPAD_RIGHT = SDL_GAMEPAD_BUTTON_DPAD_RIGHT,
        LEFT_PADDLE1 = SDL_GAMEPAD_BUTTON_LEFT_PADDLE1,
        LEFT_PADDLE2 = SDL_GAMEPAD_BUTTON_LEFT_PADDLE2,
        RIGHT_PADDLE1 = SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1,
        RIGHT_PADDLE2 = SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2,
        RIGHT_SHOULDER = SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
        RIGHT_STICK = SDL_GAMEPAD_BUTTON_RIGHT_STICK,
        LEFT_SHOULDER = SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
        LEFT_STICK = SDL_GAMEPAD_BUTTON_LEFT_STICK,
        BACK = SDL_GAMEPAD_BUTTON_BACK,
        COUNT = SDL_GAMEPAD_BUTTON_COUNT,
        MISC1 = SDL_GAMEPAD_BUTTON_MISC1,
        MISC2 = SDL_GAMEPAD_BUTTON_MISC2,
        MISC3 = SDL_GAMEPAD_BUTTON_MISC3,
        MISC4 = SDL_GAMEPAD_BUTTON_MISC4,
        MISC5 = SDL_GAMEPAD_BUTTON_MISC5,
        MISC6 = SDL_GAMEPAD_BUTTON_MISC6,
        GUIDE = SDL_GAMEPAD_BUTTON_GUIDE,
        INVALID = SDL_GAMEPAD_BUTTON_INVALID
    };
    Q_ENUM(BUTTON)
};

// Bind gamepad buttons to keyboard keys
class GAMEPAD_KEYS : public QObject
{
    Q_OBJECT;
    QML_NAMED_ELEMENT(GamepadKeys);
    QML_SINGLETON;

public:
    enum class BUTTON {
        PRIMARY = Qt::Key_Space,
        SECONDARY = Qt::Key_X,
        TERTIARY = Qt::Key_C,
        BACK = Qt::Key_Escape,
        LEFT_BUMPER = Qt::Key_BracketLeft,
        RIGHT_BUMPER = Qt::Key_BracketRight
    };
    Q_ENUM(BUTTON)
};
