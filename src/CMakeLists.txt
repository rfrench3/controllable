# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>

add_executable(example-app)

ecm_add_qml_module(example-app
    URI
    io.github.rfrench3.exampleapp
)

target_sources(example-app
    PRIVATE
    main.cpp
)

ecm_target_qml_sources(example-app
    SOURCES
    Main.qml
)

target_link_libraries(example-app
    PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Widgets
    Qt6::Quick
    Qt6::QuickControls2
    
    KF6::I18n
    KF6::I18nQml
    KF6::IconThemes
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    
    controllable
)

install(TARGETS example-app ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

add_subdirectory(controllable)
