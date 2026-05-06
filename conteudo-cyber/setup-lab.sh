#!/usr/bin/env bash
# setup-lab.sh — Script de setup do Deep Eye em ambiente de lab
# Uso: chmod +x setup-lab.sh && ./setup-lab.sh

set -e

DEEP_EYE_DIR="$HOME/lab/deep-eye"
VENV_DIR="$DEEP_EYE_DIR/venv"

echo "[*] Clonando Deep Eye..."
mkdir -p "$HOME/lab"
if [ ! -d "$DEEP_EYE_DIR" ]; then
    git clone https://github.com/zakirkun/deep-eye.git "$DEEP_EYE_DIR"
else
    echo "[~] Diretório já existe, pulando clone."
fi

echo "[*] Criando ambiente virtual Python..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "[*] Instalando dependências..."
pip install --upgrade pip -q
pip install -r "$DEEP_EYE_DIR/requirements.txt" -q

echo "[*] Copiando template de configuração..."
if [ ! -f "$DEEP_EYE_DIR/config/config.yaml" ]; then
    cp "$DEEP_EYE_DIR/config/config.example.yaml" "$DEEP_EYE_DIR/config/config.yaml"
    echo "[!] Editar config.yaml com suas API keys antes de usar:"
    echo "    nano $DEEP_EYE_DIR/config/config.yaml"
else
    echo "[~] config.yaml já existe, mantendo."
fi

echo ""
echo "[✓] Setup concluído."
echo ""
echo "    Para ativar o ambiente:"
echo "    source $VENV_DIR/bin/activate"
echo ""
echo "    Para executar um scan:"
echo "    cd $DEEP_EYE_DIR && python deep_eye.py -u https://alvo-autorizado.com"
echo ""
echo "    ⚠️  Usar apenas em sistemas com autorização explícita."
