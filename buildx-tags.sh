#!/bin/sh

# Install buildx
# Post https://devdotnet.org/post/sborka-docker-konteinerov-dlya-arm-arhitekturi-ispolzuya-buildx/

# $ chmod +x buildx-tags.sh
# $ ./buildx-tags.sh

set -feu

printf 'Start BUILDX\n'

export ORG="${ORG:-devdotnetorg}"
export DOCKER_ARGS="${DOCKER_ARGS:---push}"
if [ -z ${IMAGES+x} ]; then
  # Alpine Linux
  IMAGES='alpine:3.16 alpine:3.17 alpine:3.18 alpine:3.19 alpine:3.20 alpine:3.21 alpine:edge'
  # Ubuntu
  IMAGES="${IMAGES}"' ubuntu:16.04 ubuntu:18.04 ubuntu:20.04 ubuntu:22.04 ubuntu:24.04'
  # Debian
  IMAGES="${IMAGES}"' debian:10 debian:11 debian:12 debian:sid'
  export IMAGES
fi

#:alpine 3.16, 3.17, 3.18, 3.19, 3.20
#:ubuntu 16.04, 18.04, 20.04, 22.04, 24.04
#:debian 10, 11, 12
for IMAGE_VERSION in ${IMAGES}
do
  #
  IMAGE_VERSION_2=$(printf '%s' "${IMAGE_VERSION}" | tr : -)
  export IMAGE_VERSION_2
  # build
  printf 'BUILD image: %s\n' "${IMAGE_VERSION}"
  case "${IMAGE_VERSION}" in
    *'alpine'*)
        docker buildx build --platform 'linux/arm,linux/arm64,linux/amd64' -f 'alpine.Dockerfile' --build-arg IMAGE_VERSION="${IMAGE_VERSION}" -t "${ORG}"'/openssh-server':"${IMAGE_VERSION_2}" . "${DOCKER_ARGS}"
    ;;
    *'ubuntu'*|*'debian'*)
        docker buildx build --platform 'linux/arm,linux/arm64,linux/amd64' -f 'ubuntu.Dockerfile' --build-arg IMAGE_VERSION="${IMAGE_VERSION}" -t "${ORG}"'/openssh-server':"${IMAGE_VERSION_2}" . "${DOCKER_ARGS}"
    ;;
  esac
  #
done

#latest ubuntu:24.04
case "${IMAGES}" in
  *'ubuntu:24.04'*)
    docker buildx build --platform 'linux/arm,linux/arm64,linux/amd64' -f 'ubuntu.Dockerfile' --build-arg IMAGE_VERSION='ubuntu:24.04' -t "${ORG}"'/openssh-server':'ubuntu' . "${DOCKER_ARGS}"
  ;;
esac

#latest debian:12
case "${IMAGES}" in
  *'debian:12'*)
    docker buildx build --platform 'linux/arm,linux/arm64,linux/amd64' -f 'ubuntu.Dockerfile' --build-arg IMAGE_VERSION='debian:12' -t "${ORG}"'/openssh-server':'debian' . "${DOCKER_ARGS}"
  ;;
esac

#latest alpine:3.20
case "${IMAGES}" in
  *'alpine:3.20'*)
    docker buildx build --platform 'linux/arm,linux/arm64,linux/amd64' -f 'alpine.Dockerfile' --build-arg IMAGE_VERSION='alpine:3.20' -t "${ORG}"'/openssh-server':'alpine' . "${DOCKER_ARGS}"
  ;;
esac

# RISC-V (riscv64)
#:ubuntu-riscv64
case "${IMAGES}" in
  *'ubuntu:22.04'*)
    docker buildx build --platform 'linux/riscv64' -f 'ubuntu.Dockerfile' --build-arg IMAGE_VERSION='riscv64/ubuntu:22.04' -t "${ORG}"'/openssh-server':'ubuntu-riscv64' . "${DOCKER_ARGS}"
  ;;
esac

#:debian-riscv64
case "${IMAGES}" in
  *'debian:sid'*)
    docker buildx build --platform 'linux/riscv64' -f 'ubuntu.Dockerfile' --build-arg IMAGE_VERSION='riscv64/debian:sid' -t "${ORG}"'/openssh-server':'debian-riscv64' . "${DOCKER_ARGS}"
  ;;
esac

#:alpine-riscv64
case "${IMAGES}" in
  *'alpine:edge'*)
    docker buildx build --platform 'linux/riscv64' -f 'alpine.Dockerfile' --build-arg IMAGE_VERSION='riscv64/alpine:edge' -t "${ORG}"'/openssh-server':'alpine-riscv64' . "${DOCKER_ARGS}"
  ;;
esac

#:latest ubuntu:24.04
case "${IMAGES}" in
  *'ubuntu:24.04'*)
    docker buildx build --platform 'linux/arm,linux/arm64,linux/amd64' -f 'ubuntu.Dockerfile' --build-arg IMAGE_VERSION='ubuntu:24.04' -t "${ORG}"'/openssh-server':'latest' . "${DOCKER_ARGS}"
  ;;
esac

printf 'BUILDX END\n'
