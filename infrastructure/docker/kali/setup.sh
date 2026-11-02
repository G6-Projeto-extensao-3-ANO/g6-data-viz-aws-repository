#!/usr/bin/env bash

set -Eeuo pipefail

echo "========================================="
echo "Configurando imagem Kali para o Kasm"
echo "========================================="

if [ "$(id -u)" -ne 0 ]; then
    echo "ERRO: execute este script como root."
    exit 1
fi

# Confirma que o usuário padrão existe.
if ! id kasm-user >/dev/null 2>&1; then
    echo "ERRO: o usuário kasm-user não existe na imagem-base."
    exit 1
fi

# A imagem deve utilizar somente os repositórios Kali Rolling.
# Isso evita misturar versões de pacotes do Debian Unstable.
mkdir -p /etc/apt/sources.list.d

find /etc/apt/sources.list.d \
    -maxdepth 1 -type f \
    -delete

cat > /etc/apt/sources.list <<'EOF'
deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF

# Obtém e valida a chave oficial de assinatura do Kali.
# Não desativa a validação GPG do APT.
KEY_URL="https://archive.kali.org/archive-key.asc"
KEY_FILE="$(mktemp)"
GNUPG_HOME="$(mktemp -d)"

cleanup() {
    rm -f "$KEY_FILE"
    rm -rf "$GNUPG_HOME"
}
trap cleanup EXIT

export GNUPGHOME="$GNUPG_HOME"

if command -v curl >/dev/null 2>&1; then
    curl --fail --silent --show-error --location \
        "$KEY_URL" -o "$KEY_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$KEY_URL" -O "$KEY_FILE"
else
    echo "ERRO: curl ou wget é necessário para obter a chave oficial."
    exit 1
fi

# Confirma a impressão digital publicada pelo Kali.
FINGERPRINT="$(
    gpg --batch --show-keys --with-colons "$KEY_FILE" |
    awk -F: '$1 == "fpr" { print toupper($10); exit }'
)"

EXPECTED_FINGERPRINT="827C8569F2518CC677FECA1AED65462EC8D5E4C5"

if [ "$FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]; then
    echo "ERRO: impressão digital inesperada para a chave do Kali."
    echo "Obtida: $FINGERPRINT"
    exit 1
fi

install -d -m 0755 /usr/share/keyrings

gpg --batch --yes --dearmor \
    --output /usr/share/keyrings/kali-archive-keyring.gpg \
    "$KEY_FILE"

chmod 0644 /usr/share/keyrings/kali-archive-keyring.gpg

# Usa a chave verificada explicitamente pelo repositório.
cat > /etc/apt/sources.list.d/kali.sources <<'EOF'
Types: deb
URIs: http://http.kali.org/kali/
Suites: kali-rolling
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/kali-archive-keyring.gpg
EOF

# Atualiza o índice e instala apenas os pacotes necessários.
apt-get update

apt-get install -y --no-install-recommends \
    sudo \
    nano \
    nmap \
    hydra \
    autopsy \
    sleuthkit

# Configura o sudo sem duplicar linhas a cada execução.
# NOPASSWD é intencional para o laboratório descartável.
install -d -m 0750 /etc/sudoers.d

printf '%s\n' \
    'kasm-user ALL=(ALL:ALL) NOPASSWD: ALL' \
    > /etc/sudoers.d/kasm-user

chmod 0440 /etc/sudoers.d/kasm-user

visudo -cf /etc/sudoers

# Garante a propriedade do diretório pessoal.
mkdir -p /home/kasm-user
chown -R 1000:1000 /home/kasm-user

echo "========================================="
echo "Configuração concluída"
echo "========================================="

id kasm-user
nmap --version | head -n 2
hydra -h 2>&1 | head -n 2
