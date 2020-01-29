#!/usr/bin/env sh
# SkyCam startup script
# To be run at reboot by root cront job
# Currently does:
# - Check if wired interface has been assigned an interface.
#   If not, then start a dhcp server.

# 0) Check if run as root
if [ "$(id -u)" != "0" ]; then
  printf "%s\n" "Must be run as root" 1>&2
  exit 1
fi

# Print date
date

# 1) Wait 90 seconds for an ip on wired interface
RETRIES_IP=0
while [ "$RETRIES_IP" -lt 9 ]; do
    if ip route  | grep -E "eth0.*dhcp">/dev/null 2>&1; then 
        # Wired interface has an ip, do nothing else.
        printf "%s\n" "eth0 has an ip assigned already!"
        exit 0
    else
        # Sleep for 10 seconds
        sleep 10
        RETRIES_IP=$(( RETRIES_IP + 1 ))
    fi
done

# 2) If not, start dhcpd server on wired interface
# To launch DHCP server on a single interface, copy and rename a system service template.
printf "%s\n" "Starting DHCP server on eth0"
INTERFACE=eth0
SERV_NAME="dhcpd4@eth0.service"

ip link set up dev eth0
ip addr add 192.168.100.1/16 dev eth0
systemctl daemon-reload
systemctl start "$SERV_NAME" || exit 1


# 3) TODO: Enable wifi hotspot


exit 0
