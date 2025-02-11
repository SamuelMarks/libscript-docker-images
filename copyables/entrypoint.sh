#!/bin/bash
printf 'Start entrypoint.sh\n'

set -e
set +f

# Folder for sshd. No Change.
mkdir -p /var/run/sshd

# Key generation
ls /etc/ssh/ssh_host_* >/dev/null 2>&1 && printf 'Keys is found\n' || printf 'Key generation.\n' && ssh-keygen -A

# Environment variables that are used if not empty:
# USER_PASSWORD

#Set password
if [ -f /.ispasswordset ]; then
    printf 'Password already set\n'
else
    printf 'Set  password of user for sshd\n'
    case "${USER_PASSWORD}" in
      'null'|'')
        case "${USER_PUBKEY}" in
            'null'|'')
              >&2 printf 'Set one of USER_PASSWORD xor USER_PUBKEY\n'
              exit 3
              ;;
            *)
              printf '%s\n' "${USER_PUBKEY}" >> /root/.ssh/authorized_keys ;;
        esac
        ;;
      *)
        printf 'root:%s' "${USER_PASSWORD}" |chpasswd ;;
      esac
    touch /.ispasswordset
fi

printf 'Run sshd\n'

exec "$@"
