#!/bin/bash

set -euo pipefail

# Install Wireguard. This has to be done dynamically since the kernel
# module depends on the host kernel version.
apt update
# Kernel headers should be mounted through volume on RancherOS. See Readme.
# apt install -y linux-headers-$(uname -r)
apt install -y wireguard

# Find a Wireguard interface
interfaces=`find /etc/wireguard -type f`
if [[ -z $interfaces ]]; then
    echo "$(date): Interface not found in /etc/wireguard" >&2
    exit 1
fi

interface=`echo $interfaces | head -n 1`

echo "$(date): Starting Wireguard"
wg-quick up $interface

VPN_IP=$(grep -Po 'Endpoint\s=\s\K[^:]*' $interfaces)

# Handle shutdown behavior
function finish () {
    echo "$(date): Shutting down Wireguard"
    wg-quick down $interface
    exit 0
}

# Our IP address should be the VPN endpoint for the duration of the
# container, so this function will give us a true or false if our IP is
# actually the same as the VPN's
function has_vpn_ip {
    curl --silent --show-error --retry 10 --fail http://checkip.dyndns.com/ | \
        grep $VPN_IP
}

# If our container is terminated or interrupted, we'll be tidy and bring down
# the vpn
trap finish SIGTERM SIGINT SIGQUIT

# Every minute we check to our IP address
while [[ has_vpn_ip ]]; do
    sleep 60;
done

echo "$(date): VPN IP address not detected"
