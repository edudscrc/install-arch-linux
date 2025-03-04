#!/bin/bash

CONFIG_DIR="$HOME/.config/hypr"
HDR_CONFIG="$CONFIG_DIR/hyprland_hdr.conf"
NON_HDR_CONFIG="$CONFIG_DIR/hyprland_non_hdr.conf"
CURRENT_CONFIG="$CONFIG_DIR/hyprland.conf"
TEMP_FILE="$CONFIG_DIR/.temp_swap"

# Verifica se os arquivos existem
if [[ ! -f "$HDR_CONFIG" || ! -f "$NON_HDR_CONFIG" ]]; then
    echo "Erro: Um ou ambos os arquivos de configuração não existem."
    exit 1
fi

# Identifica qual está em uso e troca
if cmp -s "$CURRENT_CONFIG" "$HDR_CONFIG"; then
    mv "$NON_HDR_CONFIG" "$TEMP_FILE"
    mv "$CURRENT_CONFIG" "$NON_HDR_CONFIG"
    mv "$TEMP_FILE" "$CURRENT_CONFIG"
    echo "Alternado para configuração SEM HDR"
else
    mv "$HDR_CONFIG" "$TEMP_FILE"
    mv "$CURRENT_CONFIG" "$HDR_CONFIG"
    mv "$TEMP_FILE" "$CURRENT_CONFIG"
    echo "Alternado para configuração COM HDR"
fi

# Reinicia o Hyprland
hyprctl reload
