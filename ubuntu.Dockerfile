###########################################
# Official Image Ubuntu with OpenSSH server
# Allow SSH connection to the container
# Installed: openssh-server, mc, htop, zip,
# tar, iotop, ncdu, nano, vim, bash, sudo
# for net: ping, traceroute, telnet, host,
# nslookup, iperf, nmap
###########################################

ARG IMAGE_VERSION="ubuntu:24.04"

FROM $IMAGE_VERSION
# Label docker image
ARG IMAGE_VERSION
MAINTAINER DevDotNet.Org <anton@devdotnet.org>
LABEL maintainer="DevDotNet.Org <anton@devdotnet.org>"
LABEL build_version="Image version:- ${IMAGE_VERSION}"

# Base
# Set the locale

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US.UTF-8'

# Password for ssh
ENV USER_PASSWORD=123456
# Pubkey alternative for ssh (set one or the other)
ENV USER_PUBKEY='null'

# Copy to image
COPY copyables /

# Install
RUN <<-EOF
set -eu +f
case "${USER_PASSWORD}" in
  'null'|'')
    case "${USER_PUBKEY}" in
      'null'|'')
        >&2 printf 'Set USER_PASSWORD xor USER_PUBKEY\n' ;
        exit 3 ;
      ;;
    esac
    ;;
esac ;
apt-get update &&
apt-get -y upgrade &&
apt-get install -y openssh-server &&
# Utils
apt-get install -y mc htop iotop ncdu tar zip nano vim bash sudo sed &&
# Net utils
apt-get install -y iputils-ping traceroute telnet iperf nmap &&
apt-get install -y dnsutils || true &&
# Deleting keys
rm -rf /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa* /etc/ssh/ssh_host_ed25519* /etc/ssh/ssh_host_rsa* &&
# Config SSH
sed -ri "s|^#PermitRootLogin|PermitRootLogin|" /etc/ssh/sshd_config &&
sed -i "s|PermitRootLogin without-password|PermitRootLogin yes|" /etc/ssh/sshd_config &&
case "${USER_PUBKEY}" in
  'null'|'')
    sed -i "s|PermitRootLogin prohibit-password|PermitRootLogin yes|" /etc/ssh/sshd_config ;
    sed -ri "s|^#PasswordAuthentication|PasswordAuthentication|" /etc/ssh/sshd_config ;
    sed -ri "s|^PasswordAuthentication no|PasswordAuthentication yes|" /etc/ssh/sshd_config ;
  ;;
esac ;
sed -ri "s|^#?PermitRootLogin\s+.*|PermitRootLogin yes|" /etc/ssh/sshd_config &&
sed -ri "s|UsePAM yes|#UsePAM yes|g" /etc/ssh/sshd_config &&
# Folder Data
mkdir -p /data &&
# Cleaning
apt-get clean autoclean -y &&
apt-get autoremove -y &&
rm -rf /var/lib/{apt,dpkg,cache,log}/ &&
rm -rf /var/lib/apt/lists/*.lz4 &&
rm -rf /var/log/* &&
rm -rf /tmp/* &&
rm -rf /var/tmp/* &&
rm -rf /usr/share/doc/ &&
rm -rf /usr/share/man/ &&
rm -rf $HOME/.cache &&
chmod +x /entrypoint.sh

EOF

# Port SSH
EXPOSE 22/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]
