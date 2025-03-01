###########################################
# Official Image Alpine with OpenSSH server
# Allow SSH connection to the container
# Installed: openssh-server, rsync, curl,
# jq, envsubst, pandoc, crc32
###########################################

ARG IMAGE_VERSION="alpine:3.20"

FROM $IMAGE_VERSION
# Label docker image
ARG IMAGE_VERSION
LABEL io.offscale.libscript_docker_images.maintainers="Samuel Marks <807580+SamuelMarks@users.noreply.github.com>"
LABEL maintainer="Samuel Marks <807580+SamuelMarks@users.noreply.github.com>"
LABEL build_version="Image version:- ${IMAGE_VERSION}"

# Base
# Set the locale

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US.UTF-8'

# Password for ssh
ENV USER_PASSWORD='123456'
# Pubkey alternative for ssh (set one or the other)
ENV USER_PUBKEY='null'

# Copy to image
COPY copyables /

# Install
RUN <<-EOF
set -eu +f ;
apk update &&
apk add --no-cache --upgrade openssh-server rsync jq curl perl-archive-zip &&
apk add --no-cache gettext-envsubst --repository='https://dl-cdn.alpinelinux.org/alpine/edge/main' &&
apk add --no-cache pandoc-cli --repository='https://dl-cdn.alpinelinux.org/alpine/edge/community' &&
# Deleting keys
rm -rf '/etc/ssh/ssh_host_dsa'* '/etc/ssh/ssh_host_ecdsa'* '/etc/ssh/ssh_host_ed25519'* '/etc/ssh/ssh_host_rsa'* &&
# Config SSH
sed -ri 's|^#PermitRootLogin|PermitRootLogin|' '/etc/ssh/sshd_config' &&
sed -ri 's|^#?PermitRootLogin\s+.*|PermitRootLogin yes|' '/etc/ssh/sshd_config' &&
# Folder Data
mkdir -p '/data' &&
# Cleaning
rm -rf '/var/lib'/{apt,dpkg,cache,log}/ &&
rm -rf '/var/lib/apt/lists'/*.lz4 &&
rm -rf '/var/log'/* &&
rm -rf '/tmp'/* &&
rm -rf '/var/tmp'/* &&
rm -rf '/usr/share/doc/' &&
rm -rf '/usr/share/man/' &&
rm -rf '/var/cache/apk'/* &&
rm -rf "${HOME}"'/.cache' &&
chmod +x '/entrypoint.sh'

EOF

# Port SSH
EXPOSE 22/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]
