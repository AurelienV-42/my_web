#!/bin/bash

# This install is only for Ubuntu
# Mode debug : bash -x <script_name>

# Script Constante
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
APP_DIR=$(cd ${SCRIPT_PATH}/.. && pwd)
DIRECTORY_BLIH="${APP_DIR}/.files/"
regex="^[Oo]([Uu][Ii])?$"

# Add Here Alias, first is the alias and the second is the command
aliases=('ne' 'emacs -nw' 'ga' 'git add --all' 'gc' 'git commit -m $1' 'gp' 'git push'
'gch' 'git checkout $1' 'gtag' 'git tag $1' 'gtaga' 'git tag -a $1 $2')

echo "Début du script..."

echo "Mise à jour..."

# Récupération de la liste des paquets non mis à jour
sudo apt-get update

# Installation des paquets à mettre à jour
sudo apt-get upgrade

# Installation de zsh, curl et ssh
sudo apt-get install zsh curl ssh htop tree terminator libncurses5 ocaml valgrind build-essential gcc intel-microcode emacs python3

# Setup d'emacs
read -p "Setup d'emacs, quel est votre login epitech ? " login
mkdir tmp
dir_tmp=$(pwd)/tmp
emacs_tmp=$dir_tmp/.emacs.d
cp -r $DIRECTORY_BLIH/.emacs.d $dir_tmp
sed 's/(getenv "USER")/"'$login'"/g' $emacs_tmp/epitech/std_comment.el > $emacs_tmp/epitech/std_comment.el.tmp
mv $emacs_tmp/epitech/std_comment.el.tmp $emacs_tmp/epitech/std_comment.el
cp $DIRECTORY_BLIH/.emacs $HOME/
chmod +rw $HOME/.emacs
cp -r $emacs_tmp $HOME/
chmod +rw $HOME/.emacs.d
chmod +rw $HOME/.emacs.d/*
rm -rf tmp

# Installation de blih
echo "Installation de blih..."
sudo cp "${DIRECTORY_BLIH}blih" /usr/bin/
sudo chmod 755 /usr/bin/blih

# Installation de Clion
read -p "Souhaitez-vous installer Clion ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    mkdir tmp
    cd tmp
    wget https://download.jetbrains.com/cpp/CLion-2016.1.3.tar.gz
    tar zxvf Clion-2016.1.3.tar.gz
    rm *.tar.gz
    mv * ${HOME}/.clion
    cd ..
    rm -rf tmp/
fi

# Installation de Discord
read -p "Souhaitez-vous installer Discord ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    sudo snap install discord
fi

# Add export to change the editor and add the .bin path 
echo -e "\n# Export to change the editor and add the .bin path
export VISUAL=emacs
export EDITOR=\$VISUAL
export PATH=\$PATH:\$HOME/.bin" >> $HOME/.zshrc

## Git tag permet de rajouter des numéros de versions à propos de certains commit
## Pour créer un tag sur le dernier commit :
## gtag <nom du tag>
## Si des tags ont été oublié pour certains commit, faites la commande suivante :
## gtaga <nom du tag> <nom du commit>
## Pour voir à quelles commits un tag est attribué, faites la commande suivante :
## git show <nom du tag>

# Création des alias
echo -e "\n# Alias Section" >> $HOME/.zshrc
i=0
for alias in "${aliases[@]}"; do
    if (( $i%2 == 0 )); then
        if [ $i != 0 ]; then
            echo -e "${first}\n${second}" | $APP_DIR/bin/create_alias
            second=''
        fi
        first=${alias}
    else
        second=${alias}
    fi
    i=$((i+1))
done

# Création du directory .bin dans le dossier HOME de l'utilisateur
if [ ! -d $HOME/.bin ] ; then
    mkdir $HOME/.bin

fi

# On rend le binaire create_alias executable de n'importe où
if [ ! -f $HOME/.bin/create_alias ] ; then
    cp $APP_DIR/bin/create_alias $HOME/.bin
fi

# Utilisation du create_alias
add_alias=0
while [ $add_alias == 0 ]; do
    read -p "Souhaitez-vous créer des alias? (o/N): " answer
    if [[ "$answer" =~ $regex ]]; then
        ./create_alias
    else
        add_alias=1
    fi
done

# Génération des clés ssh
read -p "Souhaitez-vous générer les clés ssh? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    ssh-keygen
fi

# Upload de la clé ssh sur les repos d'epitech
read -p "Souhaitez-vous upload votre clé ssh sur les repos d'epitech ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    echo "Mot de passe UNIX (bocal, pour blih)"
    blih -u "$1" sshkey upload $HOME/.ssh/id_rsa.pub
fi

# Changement des droits sur poweroff et reboot pour pouvoir les utiliser sans sudo
sudo chmod +s /sbin/poweroff
sudo chmod +s /sbin/reboot

read -p "Souhaitez-vous ouvrir Clion (pour créer les raccourcis ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    ${HOME}/.clion/bin/clion.sh
fi

# Reset sudo, next time you will need a password
sudo -k

# Installation de oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
