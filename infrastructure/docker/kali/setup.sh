#!/bin/bash

set -e

echo "========================================="
echo " Inicializando Kali Linux"
echo "========================================="

# Inicia o entrypoint original da imagem
/entrypoint.sh &

KASM_PID=$!

echo "Aguardando o Kali inicializar..."

sleep 30

echo "Configurando usuários..."

# Senha do kasm-user
echo "kasm-user:urubu100" | chpasswd

# Sudo
echo "kasm-user ALL=(ALL) ALL" >> /etc/sudoers

# Compatibilidade caso o usuário com hífen exista
if id "kasm-user" >/dev/null 2>&1; then
    echo "kasm-user:urubu100" | chpasswd
    echo "kasm-user ALL=(ALL) ALL" >> /etc/sudoers
fi

echo "Atualizando repositórios..."

apt-get update

echo "Instalando ferramentas..."

apt-get install -y \
    nmap \
    autopsy \
    sleuthkit \
    hydra

echo "========================================="
echo " Kali configurado"
echo "========================================="

# Mantém o container vivo acompanhando o processo original
wait $KASM_PID