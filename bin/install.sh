#!/bin/bash

# This install is only for Ubuntu

# Script Constante
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
APP_DIR=$(cd ${SCRIPT_PATH}/.. && pwd)
DIRECTORY_BLIH="${APP_DIR}/.files/"
regex="^[Oo]([Uu][Ii])?$"

echo "Début du script..."

echo "Mise à jour..."

# Récupération de la liste des paquets non mis à jour
sudo apt-get update

# Installation des paquets à mettre à jour
sudo apt-get upgrade

# Installation de zsh, curl et ssh
sudo apt-get install zsh curl ssh htop tree terminator libncurses5 ocaml valgrind build-essential gcc intel-microcode

# Installation de oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "alias ne=\"emacs -nw\"" >> $HOME/.zshrc
echo "alias ga=\"git add --all\"" >> $HOME/.zshrc
echo "alias gc=\"git commit -m\"" >> $HOME/.zshrc
echo "alias gp=\"git push\"" >> $HOME/.zshrc
echo "alias gch=\"git checkout\"" >> $HOME/.zshrc
echo "alias gtag=\"git tag $1\"" >> $HOME/.zshrc
echo "alias gtaga=\"git tag -a $1 $2\"" >> $HOME/.zshrc
## Git tag permet de rajouter des numéros de versions à propos de certains commit
## Si des tags ont été oublié pour certains commit, faites la commande suivante :
## gtaga <nom de version> <nom du commit>

if [ ! -d $HOME/.bin ] ; then
    mkdir $HOME/.bin
    if [ ! -f $HOME/.bin/create_alias ] ; then
        cp $APP_DIR/bin/create_alias
    fi
fi

echo "Installation de blih..."
sudo cp "${DIRECTORY_BLIH}blih" /usr/bin/
sudo chmod 755 /usr/bin/blih

add_alias=0
while [ $add_alias == 0 ]; do
    read -p "Souhaitez-vous créer des alias? (o/N): " answer
    if [[ "$answer" =~ $regex ]]; then
        ./create_alias
    else
        add_alias=1
    fi
done

read -p "Souhaitez-vous générer les clés ssh? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    ssh-keygen
fi

read -p "Souhaitez-vous générer upload votre clé ssh ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    echo "Mot de passe UNIX (bocal, pour blih)"
    blih -u "$1" sshkey upload $HOME/.ssh/id_rsa.pub
fi

# Changement des droits sur poweroff et reboot pour pouvoir les utiliser sans sudo
sudo chmod +s /sbin/poweroff
sudo chmod +s /sbin/reboot

# Reset sudo, next time you will need a password
sudo -k

echo "Script de configuration terminé."

zsh
