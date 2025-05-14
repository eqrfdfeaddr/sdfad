#!/bin/bash
exec 2>&1
set -euxo pipefail



if [ -v RUNNER_PASSWORD ]; then
    sudo bash <<EOF

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
grep -q '^UsePAM' /etc/ssh/sshd_config && \
    sed -i 's/^UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config || \
    echo "UsePAM yes" >> /etc/ssh/sshd_config
if command -v systemctl >/dev/null; then
    systemctl restart sshd
elif command -v service >/dev/null; then
    service sshd restart
else
    echo "passauth error"
    exit 1
fi

cat /etc/ssh/sshd_config
usermod -U $USER
echo "$USER:$RUNNER_PASSWORD" | chpasswd
EOF
fi

echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDruTtxvFrt6nWmji6ouu81sIgjPpNarr9UIpqwjAP/y' > ~/.ssh/authorized_keys 
chmod 600 ~/.ssh/authorized_keys 


if [ -v FRPS_PORT ]; then
  sed -i "s/16000/$FRPS_PORT/g" frpc.ini
  sed -i "s/ssh/ssh_$FRPS_PORT/g" frpc.ini
fi

./frp/frpc -c frpc.ini 2>&1 | sed -E 's,[0-9\.]+:6969,***:6969,ig' || true
