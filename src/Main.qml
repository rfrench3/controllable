// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import io.github.rfrench3.controllable as Gamepad

ApplicationWindow {
    id: root
    visible: true


    Gamepad.GamepadPageNavigation {
        
    }

    StackView {
        anchors.fill: parent

        Text {text: "text"}
    }
}
