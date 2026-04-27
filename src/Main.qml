// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import io.github.rfrench3.controllable as Gamepad

ApplicationWindow {
    id: root
    visible: true


    // Gamepad.PageNavigation {
    //     targetScrollbar: view.ScrollBar.vertical   
    // }

    // ScrollView {
    //     id: view
    //     anchors.fill: parent

    //     ListView {
    //         model: 200
    //         delegate: ItemDelegate {
    //             text: "Item " + index + " " + Gamepad.Gamepad.rightY

    //             required property int index
    //         }
    //     }
    // }

    Gamepad.ScrollHandler {
        scrollBar: view.ScrollBar.vertical
    }


    ScrollView {
        id: view
        anchors.fill: parent
        

        ListView {
            model: 200
            delegate: ItemDelegate {
                text: "Item " + index

                required property int index
            }
        }
    }

    


}
