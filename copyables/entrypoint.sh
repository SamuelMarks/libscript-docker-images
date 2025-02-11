#!/bin/bash
echo "Start entrypoint.sh"

set -e

# Folder for sshd. No Change.
mkdir -p /var/run/sshd

# Key generation
ls /etc/ssh/ssh_host_* >/dev/null 2>&1 &&echo "Keys is found" ||echo "Key generation." && ssh-keygen -A

# Environment variables that are used if not empty:
# USER_PASSWORD

#Set password
if [ -f /.ispasswordset ]; then
    echo "Password already set"
else
    echo "Set  password of user for sshd"
    if [ ! -z "${USER_PASSWORD+x}" ]; then
      echo 'root:'"${USER_PASSWORD}" |chpasswd
    elif [ ! -z "${USER_PUBKEY+x}" ]; then
      printf '%s\n' "${USER_PUBKEY}" > /root/.ssh/authorized_keys
    else
      >&2 printf 'Set one of USER_PASSWORD xor USER_PUBKEY\n'
      exit 3
    fi
    touch /.ispasswordset
fi

echo "Run sshd"

exec "$@"