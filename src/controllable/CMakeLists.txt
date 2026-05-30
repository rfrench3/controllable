# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

add_library(qt6-controllable)

ecm_add_qml_module(qt6-controllable
    URI "io.github.rfrench3.controllable"
    GENERATE_PLUGIN_SOURCE
)

target_sources(qt6-controllable
    PRIVATE
    controllers.cpp
    controllers.h
    labels.cpp
    labels.h
)

ecm_target_qml_sources(qt6-controllable
    SOURCES
    PageNavigation.qml
    ScrollHandler.qml
)

target_link_libraries(qt6-controllable
    PRIVATE
    Qt6::Qml
    Qt6::Quick
    KF6::I18n
    SDL3::SDL3
)

ecm_finalize_qml_module(qt6-controllable)

install(TARGETS qt6-controllable ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
