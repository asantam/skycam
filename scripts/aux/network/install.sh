#!/usr/bin/env sh

# 0) Check if run as root
if [ "$(id -u)" != "0" ]; then
  printf "%s\n" "Must be run as root" 1>&2
  exit 1
fi

printf "This will overwrite network configuration files. Continue? (yes/no) "; read -r REPLY

case "$REPLY" in
  "yes")
    cp ./dhcpd4@eth0.service /etc/systemd/system/dhcpd4@eth0.service
    cp ./dhcpd.conf /etc/dhcp/dhcpd.conf
    cp ./isc-dhcp-server /etc/default/isc-dhcp-server
    ;;
  "no")
    exit 0
    ;;
  *)
    printf "%s\n" "Must reply yes or no" 1>&2
    exit 1
esac

