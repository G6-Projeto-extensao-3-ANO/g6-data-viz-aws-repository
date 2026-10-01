#!/bin/bash

set -e

echo "========================================"
echo " DEPLOY DA APLICAÇÃO"
echo "========================================"

APP_DIR="/opt/app"

echo ""
echo "[1/2] Verificando diretório da aplicação..."

mkdir -p "$APP_DIR"


echo ""
echo "[2/2] Preparando aplicação..."

cd "$APP_DIR"


echo ""
echo "========================================"
echo " DEPLOY CONCLUÍDO"
echo "========================================"