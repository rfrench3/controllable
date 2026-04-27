default:
	just --list

#devcontainer
build: 
    cmake -B build
    cmake --build build

#devcontainer
run:
    just build
    ./build/bin/example-app

#devcontainer
test:
    just build
    ctest --test-dir build --output-on-failure


#host
build-rpm:
    #!/usr/bin/env bash
    set -eou pipefail
    mkdir -p ./output
    rm -f ./output/*.rpm

    podman run --rm -v "$PWD:/workspace:z" -w /workspace fedora:43 bash -lc '
        set -eou pipefail
        dnf install -y rpm-build
        dnf builddep -y controllable.spec

        export HOME=/root
        VERSION=$(cat version.txt)
        mkdir -p ~/rpmbuild/SOURCES
        tar --transform "s|^\\.|controllable-$VERSION|" -czf ~/rpmbuild/SOURCES/$VERSION.tar.gz .
        rpmbuild -bb controllable.spec
        cp -v ~/rpmbuild/RPMS/*/*.rpm /workspace/output/
    '

#host
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