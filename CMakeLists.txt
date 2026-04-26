# SPDX-FileCopyrightText: 2025-2026 Robert French <frenchrobertm@outlook.com>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.22)

file(READ "version.txt" APP_VERSION)
project(controllable VERSION ${APP_VERSION})

find_package(SDL3 REQUIRED)

### Set up and install Qt/KDE dependencies ###

set(QT6_MIN_VERSION 6.7.0)
set(KF6_MIN_VERSION 6.12.0)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(FeatureSummary)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMFindQmlModule)
include(ECMQmlModule)

find_package(Qt6 ${QT6_MIN_VERSION} REQUIRED COMPONENTS 
    Core 
    Gui 
    Qml 
    Widgets 
    QuickControls2 
    Test
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS 
    Kirigami 
    CoreAddons 
    Config 
    I18n 
    IconThemes
)

include(KDEGitCommitHooks)
include(KDEClangFormat)

add_subdirectory(src)

# TODO: create proper tests

install(FILES ${METAINFO_OUTPUT} DESTINATION ${KDE_INSTALL_METAINFODIR})
ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

