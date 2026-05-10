FROM archlinux:latest

RUN pacman -Syu --noconfirm \
    cmake \
    git \
    extra-cmake-modules \
    sudo \
    make \
    clang \
    qt6 \
    kirigami \
    kcoreaddons \
    kconfig \
    ki18n \
    kiconthemes \
    kirigami-addons \
    qqc2-desktop-style \
    plasma-workspace \
    just

# Create user with sudo access
RUN groupadd --gid 1000 user \
    && useradd --uid 1000 --gid 1000 -m -s /bin/bash user \
    && echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user

# Give user access to the input group (for testing controllers)
RUN groupadd -f input \
    && usermod -a -G input user
