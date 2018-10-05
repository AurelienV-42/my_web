#!/bin/bash

# This install is only for Ubuntu

# Script Constante
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
APP_DIR=$(cd ${SCRIPT_PATH}/.. && pwd)

echo "Création d'un nouvel alias..."
read -p "Nouvelle commande: " new
read -p "Ancienne commande: " before
echo "alias $new=\"$before\"" >> $HOME/.zshrc
echo "alias $new=\"$before\"" >> $HOME/.bashrc
source $HOME/.bashrc
zsh
source $HOME/.zshrc