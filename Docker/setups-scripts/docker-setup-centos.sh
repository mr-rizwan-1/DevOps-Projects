#!/bin/bash

set -e

echo "=== Step 1: Remove old Docker packages ==="

sudo yum remove -y \
    docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine || true


echo "=== Step 2: Install required packages ==="

sudo yum install -y yum-utils


echo "=== Step 3: Add Docker official repository ==="

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


echo "=== Step 4: Install Docker Engine ==="

sudo yum install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin


echo "=== Step 5: Enable and start Docker ==="

sudo systemctl enable --now docker


echo "=== Step 6: Add current user to Docker group ==="

sudo usermod -aG docker "$USER"


echo "=== Docker installation completed ==="

docker --version
docker compose version