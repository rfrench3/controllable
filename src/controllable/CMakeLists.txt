# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Robert French <frenchrobertm@outlook.com>

add_library(controllable)

ecm_add_qml_module(controllable
    URI "io.github.rfrench3.controllable"
    GENERATE_PLUGIN_SOURCE
)

target_sources(controllable
    PRIVATE
    controllers.cpp
    controllers.h
    labels.cpp
    labels.h
)

ecm_target_qml_sources(controllable
    SOURCES
    PageNavigation.qml
    ScrollHandler.qml
)

target_link_libraries(controllable
    PRIVATE
    Qt6::Qml
    Qt6::Quick
    KF6::I18n
    SDL3::SDL3
)

ecm_finalize_qml_module(controllable)

install(TARGETS controllable ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
