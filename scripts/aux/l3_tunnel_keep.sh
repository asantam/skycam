#!/usr/bin/env bash

while :; do
	ps aux | grep [l]tdri3 &>/dev/null && echo "Connection already present" || ssh -f -i /home/control/.ssh/id_rsa -R 19996:localhost:22 andres@ltdri3.geog.umd.edu sleep 31536000
sleep 1m
done

exit 0
