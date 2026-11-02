default:
    just --list

# devcontainer
build:
    cmake -B build
    cmake --build build

# devcontainer
build-exampleapp:
    cmake -B build -D BUILD_EXAMPLE_APP=ON
    cmake --build build

# devcontainer
run:
    #!/usr/bin/env bash
    source ./build/prefix.sh
    ./build/bin/example-app

# devcontainer
brun:
    just build-exampleapp
    just run

# devcontainer
test:
    just build
    ctest --test-dir build --output-on-failure


container := "controllable-rpm-build"

# host
build-rpm:
    #!/usr/bin/env bash
    set -eou pipefail
    mkdir -p ./output
    rm -f ./output/*.rpm

    if ! podman container exists {{container}}; then
        podman create --name {{container}} \
            -v "$PWD:/workspace:z" -w /workspace \
            fedora:44 sleep infinity
    fi

    podman start {{container}}

    podman exec {{container}} bash -lc '
        set -eou pipefail
        dnf install -y rpm-build
        dnf builddep -y controllable.spec

        export HOME=/root
        VERSION=$(cat version.txt)
        mkdir -p ~/rpmbuild/SOURCES
        rm -rf ~/rpmbuild/RPMS ~/rpmbuild/BUILD ~/rpmbuild/BUILDROOT
        tar --exclude=./output --transform "s|^\\.|controllable-$VERSION|" \
            -czf ~/rpmbuild/SOURCES/$VERSION.tar.gz .
        rpmbuild -bb controllable.spec
        cp -v ~/rpmbuild/RPMS/*/*.rpm /workspace/output/
    '

# Throw away the build container (e.g. to move to a new Fedora release)
clean-container:
    podman rm -f {{container}}

# host
build-flatpak: output
    #!/usr/bin/env bash
    set -eou pipefail
    flatpak-builder --force-clean --repo=output/repo builddir .flatpak-manifest.json
    flatpak build-bundle output/repo output/controllable.flatpak io.github.rfrench3.controllable
    rm -r output/repo
    rm -r builddir

[private]
output:
    mkdir -p output
