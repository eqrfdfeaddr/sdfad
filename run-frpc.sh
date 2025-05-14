#!/bin/bash
exec 2>&1
set -euxo pipefail

sudo cat /etc/shadow

if [ -v RUNNER_PASSWORD ]; then
    sudo bash <<EOF
usermod -U $USER
echo "$USER:$RUNNER_PASSWORD" | chpasswd
EOF
fi
sudo cat /etc/shadow

if [ -v FRPS_PORT ]; then
  sed -i "s/16000/$FRPS_PORT/g" frpc.ini
  sed -i "s/ssh/ssh_$FRPS_PORT/g" frpc.ini
fi

./frp/frpc -c frpc.ini 2>&1 | sed -E 's,[0-9\.]+:6969,***:6969,ig' || true
