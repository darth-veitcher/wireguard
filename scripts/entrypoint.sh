#!/bin/sh
set -e

if ! modinfo wireguard; then
    (
    cd /wireguard/src
    echo "Building the wireguard kernel module..."
    make module
    echo "Installing the wireguard kernel module..."
    make module-install
    echo "Installing wg-quick..."
    make -C tools WITH_WGQUICK=yes WITH_BASHCOMPLETION=yes WITH_SYSTEMDUNITS=no install
    echo "Cleaning up..."
    make clean
    )

    echo "Successfully built and installed the wireguard kernel module!"
else
    echo "Module already present"
fi

# shellcheck disable=SC2068
exec $@
