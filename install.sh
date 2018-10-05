#!/bin/bash

# This install is only for Ubuntu

# Script Constante
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
APP_DIR=$(cd ${SCRIPT_PATH}/.. && pwd)
DIRECTORY_BLIH="./.files/"
regex="^[Oo]([Uu][Ii])?$"

echo "Début du script..."

echo "Mise à jour..."

# Récupération de la liste des paquets non mis à jour
sudo apt-get update

# Installation des paquets à mettre à jour
sudo apt-get upgrade

# Installation de zsh, curl et ssh
sudo apt-get install zsh curl ssh htop tree terminator libncurses5 ocaml valgrind build-essential gcc

# Installation de oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "alias ne=\"emacs-nw\"" >> .zshrc
echo "alias ga=\"git add --all\"" >> .zshrc
echo "alias gc=\"git commit -m\"" >> .zshrc
echo "alias gp=\"git push\"" >> .zshrc
echo "alias gch=\"git checkout\"" >> .zshrc

while [ add_alias == 0 ]; do
    read -p "Souhaitez-vous créer des alias? (o/N): " answer
    if [[ "$answer" =~ $regex ]]; then
        ./create_alias.sh
    else
        add_alias = 1
    fi
done

read -p "Souhaitez-vous générer les clés ssh? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    ssh-keygen
fi

echo "mot de passe UNIX (bocal, pour blih)"
blih -u "$1" sshkey upload $HOME/.ssh/id_rsa.pub

# Changement des droits sur poweroff et reboot pour pouvoir poweroff et reboot sans sudo
sudo chmod +s /sbin/poweroff
sudo chmod +s /sbin/reboot

# Reset sudo, next time you will need a password
sudo -k