#!/bin/sh

printf 'Start entrypoint.sh\n'

set -eu +f

# Folder for sshd. No Change.
mkdir -p -- '/var/run/sshd'

# Key generation
ls -- '/etc/ssh/ssh_host_'* >/dev/null 2>&1 && printf 'Keys is found\n' || printf 'Key generation.\n' && ssh-keygen -A

# Environment variables that are used if not empty:
#   USER_PASSWORD
#   USER_PUBKEY

[ -d '/root/.ssh' ] || mkdir -p -- '/root/.ssh'
chmod 700 '/root/.ssh'

#Set password or pubkey
if [ -f '/tmp/.isauthset' ]; then
    printf '[skip] No need to configure auth\n'
else
    # printf 'Setting user auth for sshd\n'
    sed -ri 's|^#PasswordAuthentication|PasswordAuthentication|' '/etc/ssh/sshd_config' ;
    sed -i 's|PermitRootLogin without-password|PermitRootLogin yes|' '/etc/ssh/sshd_config' ;
    sed -i 's|PermitRootLogin prohibit-password|PermitRootLogin yes|' '/etc/ssh/sshd_config' ;
    case "${USER_PASSWORD}" in
      'null'|'')
        case "${USER_PUBKEY}" in
            'null'|'')
              >&2 printf 'Set one of USER_PASSWORD xor USER_PUBKEY\n'
              exit 3
              ;;
            *)
              sed -i 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|' '/etc/ssh/sshd_config' ;
              sed -i 's|PasswordAuthentication yes|PasswordAuthentication no|' '/etc/ssh/sshd_config' ;
              sed -i 's|UsePAM yes|UsePAM no|' '/etc/ssh/sshd_config' ;
              printf '%s\n' "${USER_PUBKEY}" >> '/root/.ssh/authorized_keys'
              chmod 600 -- '/root/.ssh/authorized_keys'
              ssh-keygen -A
              # printf 'Public key set to: %s\n' "${USER_PUBKEY}"
              ;;
        esac
        ;;
      *)
        sed -ri 's|^PasswordAuthentication no|PasswordAuthentication yes|' '/etc/ssh/sshd_config' ;
        sed -ri 's|UsePAM yes|#UsePAM yes|g' '/etc/ssh/sshd_config' ;
        printf 'root:%s' "${USER_PASSWORD}" | chpasswd
        ## shellcheck disable=SC2016
        # printf 'Password has been set using ${USER_PASSWORD}\n'
        ;;
      esac
    touch -- '/tmp/.isauthset'
fi

# printf 'Run sshd\n'

exec "$@"
