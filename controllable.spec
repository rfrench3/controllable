%global orgname io.github.rfrench3.controllable

Name:           controllable
Version:        %(cat version.txt)
Release:        1%{?dist}
Summary:        QML module for controller support

License:        GPL-2.0-or-later
URL:            https://github.com/rfrench3/controllable
Source0:        %{url}/archive/refs/tags/%{version}.tar.gz

BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib

BuildRequires:  cmake
BuildRequires:  extra-cmake-modules
BuildRequires:  kf6-rpm-macros
BuildRequires:  cmake(SDL3)
BuildRequires:  cmake(Qt6Core)
BuildRequires:  cmake(Qt6Gui)
BuildRequires:  cmake(Qt6Qml)
BuildRequires:  cmake(Qt6QuickControls2)
BuildRequires:  cmake(Qt6Svg)
BuildRequires:  cmake(Qt6Widgets)

BuildRequires:  cmake(KF6Kirigami)
BuildRequires:  cmake(KF6CoreAddons)

BuildRequires:  cmake(KF6I18n)








Provides:       controllable = %{version}-%{release}

%description
A QML module that provides support for controllers.

%prep
%autosetup

%build
%cmake
%cmake_build

%install
%cmake_install

%check
appstream-util validate-relax --nonet %{buildroot}%{_kf6_metainfodir}/%{orgname}.*.xml || :

%files
%license LICENSE.txt
%doc README.md


%{_kf6_metainfodir}/%{orgname}.*.xml
%{_kf6_libdir}/libcontrollable.so
%{_kf6_qmldir}/io/github/rfrench3/controllable/*



%changelog
* Sun Apr 26 2026 Robert French
- First day of splitting this module off of bazzite updater
