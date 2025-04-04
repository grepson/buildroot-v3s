# This is a docker container if you're not natively on Linux you can compile everyting within this container

FROM debian:bullseye
    MAINTAINER Grzegorz Pietrzak <grep.pietrzak@gmail.com>

# Install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    bc \
    bison \
    flex \
    libssl-dev \
    libncurses5-dev \
    libelf-dev \
    wget \
    cpio \
    rsync \
    python3 \
    python3-setuptools \
    python3-pip \
    python3-dev \
    swig \
    python-dev \
    gcc-arm-linux-gnueabihf \
    libgnutls28-dev \
    kmod \
    u-boot-tools \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /kernel

# Example build:
# docker build -t embedded-linux-builder .

# Example usage (my case M1 max macbook pro):
#   docker run -it \
#   --cpus=$(sysctl -n hw.ncpu) --privileged \
#   -v kernel-build:/kernel \
#   --name kernel-builder embedded-linux-builder /bin/bash
