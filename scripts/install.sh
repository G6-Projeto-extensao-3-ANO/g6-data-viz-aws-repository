#!/bin/bash

set -e

echo "Preparando Ambiente (Aguarde...)"

apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    python3-venv

systemctl enable amazon-ssm-agent || true
systemctl start amazon-ssm-agent || true

install -m 0755 -d /etc/apt/keyrings

echo "Instalando Docker e Docker Compose (Aguarde...)"

apt-get install -y \
    docker.io \
    docker-compose-v2

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

echo "Verificando Docker..."
docker --version

echo "Verificando Docker Compose..."
docker compose version

echo "========================================="
echo " Ambiente preparado com sucesso!"
echo "========================================="