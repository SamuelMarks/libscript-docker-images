libscript-docker-images
-----------------------
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

SSH configured images useful as a clean environment for testing if [libscript](https://github.com/SamuelMarks/libscript) deploys correctly.

These are Docker base images for Ubuntu, Debian, Alpine with OpenSSH started.

Supports: amd64, aarch64 (ARM64v8), armhf (ARM32v7), RISC-V (riscv64).

Configurable with: password or public key authentication.

#### Upstream Links

* Docker Registry @ [samuelmarks/libscript-docker-images](https://hub.docker.com/r/samuelmarks/libscript-docker-images)
* GitHub @ [SamuelMarks/libscript-docker-images](https://github.com/SamuelMarks/libscript-docker-images)

## Features

* SSH. Allow SSH connection to the container.
* Preinstalled: `rsync`; `curl`; `jq`; `envsubst`; `pandoc`; `crc32`.

## Image Tags

Tags are defined by the mask: `samuelmarks/openssh-server:<OS_name>-<OS_version>`. For example, the image `samuelmarks/openssh-server:ubuntu-24.04` is built based on Ubuntu version 24.04.

Images for the following OS versions are builded:

* Ubuntu: 16.04, 18.04, 20.04, 22.04, 23.04, 24.04;
* Debian: 10, 11, 12;
* Alpine: 3.16, 3.17, 3.18, 3.19, 3.20, 3.21.

### Tags for RISC-V (riscv64)

* `:ubuntu-riscv64` - Ubuntu 22.04;
* `:debian-riscv64` - Debian SID;
* `:alpine-riscv64` - Alpine edge.

## Quick Start

### Private + public key setup

Alternatively to specifying `USER_PASSWORD`, you can set `USER_PUBKEY`. For example:
```sh
# Create SSH keys
printf '.ssh' | tee -a .gitignore .dockerignore >/dev/null
mkdir -- '.ssh'
ssh-keygen -t 'rsa' -b '4096' -C 'sample ssh keys' -f '.ssh/id_rsa'
```

#### Usage of public key in running container

```sh
$ docker run --name openssh-server \
    -p 2222:22 \
    -e USER_PASSWORD='null' \
    -e USER_PUBKEY="$(cat -- .ssh/id_rsa.pub)" \
    samuelmarks/openssh-server:ubuntu
```

### Environment Variables
 
Set variable of password for root user:

`-e USER_PASSWORD=123456`

Or alternatively specify `-e USER_PUBKEY` as per above.

Run container with public port for connections is `2222`, password for user root is `654321`, volume `openssh-server-data` for transfer data in/out of container:

```sh
$ docker run -d --name openssh-server \
    -p 2222:22 \
    -e USER_PASSWORD=654321 \
    -v openssh-server-data:/data \
    samuelmarks/openssh-server:ubuntu
````


For network is mynetwork:

```sh
$ docker run -d --name openssh-server \
    --net mynetwork \
    --ip 172.18.0.20 \
    -p 2222:22 \
    -e USER_PASSWORD=654321 \
    -v openssh-server-data:/data \
    samuelmarks/openssh-server:ubuntu
```

docker-compose:

```yaml
version: '3.5'
services:
  openssh-server:
    image: samuelmarks/openssh-server:ubuntu
    container_name: openssh-server
    environment:
      - USER_PASSWORD=654321
    volumes:
      - openssh-server-data:/data
    ports:
      - "2222:22"
    restart: always
    networks:
      mynetwork:
        ipv4_address: 172.18.0.20

volumes:
  openssh-server-data:
   name: openssh-server-data
   
networks:
  mynetwork:
    external: true
```

## Connect to container

Run Putty set you IP address and port `2222`

login `root`, password `654321`

Or use shell:
```sh
$ ssh root@localhost -p2222
# can use `sshpass` if you want to directly provide the password
# or `-i` if you have a private key to provide and have enabled that login
```

## Assembly for devices ##

The build for the amd64, aarch64 (ARM64v8), armhf (ARM32v7), RISC-V (riscv64) architecture was done using [buildx](https://github.com/docker/buildx).

Build script see [buildx-tags.sh](./buildx-tags.sh).

## License ##

[MIT License](https://github.com/samuelmarks/docker-openssh-server/blob/master/LICENSE).

Originally forked from https://github.com/devdotnetorg/docker-openssh-server
