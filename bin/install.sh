#!/bin/bash
#TODO Patch the bug with multiple export lines in zshrc/bashrc
# This install is only for Ubuntu
# Mode debug : bash -x <script_name>

# Script Constante
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
APP_DIR=$(cd ${SCRIPT_PATH}/.. && pwd)
conf_dir="${APP_DIR}/conf"
epitech_directory="${conf_dir}/epitech"

regex="^[Oo]([Uu][Ii])?$"

source ${conf_dir}/config

# Functions
function check_error()
{
    error=$(echo $?)
    if [[ $error != 0 ]]; then
        # Permet de renvoyer un message sur la sortie d'erreur
        echo "Une erreur s'est produite avec le code suivant : $error" 1>&2
        exit $error
    fi
}


function test_os()
{
	os=0
	which zypper &> /dev/null && os="opensuse"
	which pacman &> /dev/null && os="archlinux"
	which dnf &> /dev/null && os="fedora"
	which apt &> /dev/null && os="debian"
	which emerge &> /dev/null && os="gentoo"
    if [[ $os = 0 ]]; then
        echo -e "Votre distribution n'est pas supportée."
        exit 0
    fi
}

function upgrade()
{
    test_os

	case "$os" in
		opensuse)
			sudo zypper -y update
			;;
		archlinux)
			sudo pacman --noconfirm -Syu
			;;
		fedora)
			sudo dnf -y update
			;;
		debian)
			sudo apt -y update; sudo apt -y upgrade
			;;
		gentoo)
			sudo emerge -u world
			;;
	esac
    check_error
}

function install
{
    # On récupère le bon gestionnaire de paquet
	function get_packet_manager
	{
		case "$os" in
			opensuse)
				echo "zypper -y install"
				;;
			archlinux)
				echo "pacman --noconfirm -S"
				;;
			fedora)
				echo "dnf -y install"
				;;
			debian)
				echo "apt -y install"
				;;
			gentoo)
				echo "emerge"
				;;
		esac
	}

	if test -z "$packet_manager"; then
		packet_manager=$(get_packet_manager)
		sudo $packet_manager $package_to_install
        check_error
	fi

	if [[ $1 != '' ]]; then
	    sudo $packet_manager install $1
	fi
}

function blih_setup()
{
    if [[ ! -f /usr/bin/blih ]]; then
        echo "Installation de blih..."
        sudo cp "${epitech_directory}/blih" /usr/bin/
        sudo chmod 755 /usr/bin/blih
    fi
}

function emacs_setup()
{
    read -p "Souhaitez-vous faire le setup d'emacs (Permet d'avoir automatiquement son login dans le header) ? (o/N): " answer
    if [[ "$answer" =~ $regex ]]; then
        read -p "Quel est votre login epitech ? " login
        if [[ -f $HOME/.emacs ]]; then
            rm -rf $HOME/.emacs $HOME/.emacs.d/
        fi
        # mkdir -p permits to avoid error if tmp exist
        mkdir -p tmp
        dir_tmp=$(pwd)/tmp
        emacs_tmp=$dir_tmp/emacs.d
        cp -r $epitech_directory/emacs.d $dir_tmp
        sed 's/(getenv "USER")/"'$login'"/g' $emacs_tmp/epitech/std_comment.el > $emacs_tmp/epitech/std_comment.el.tmp
        mv $emacs_tmp/epitech/std_comment.el.tmp $emacs_tmp/epitech/std_comment.el
        cp $epitech_directory/emacs $HOME/.emacs
        chmod +rw $HOME/.emacs
        cp -r $emacs_tmp $HOME/.emacs.d
        chmod +rw $HOME/.emacs.d
        chmod +rw $HOME/.emacs.d/*
        rm -rf tmp
        echo -e "Le setup d'emacs a été effectué"
    fi
}


function clion_setup()
{
    read -p "Souhaitez-vous installer Clion ? (o/N): " answer
    # =~ Operator. When it is used, the string to the right of the operator is considered an extended regular expression and matched accordingly
    if [[ "$answer" =~ $regex ]]; then
        mkdir tmp
        cd tmp
        wget https://download.jetbrains.com/cpp/CLion-2016.1.3.tar.gz
        check_error
        tar zxvf Clion-2016.1.3.tar.gz
        rm *.tar.gz
        mv * ${HOME}/.clion
        cd ..
        rm -rf tmp/
    fi
}

function install_by_snap()
{
    read -p "Souhaitez-vous installer ${1^} ? (o/N): " answer
    if [[ "$answer" =~ $regex ]]; then
        sudo snap install $1
        check_error
    fi
}

function add_export()
{
    if [[ ! `grep "# Export to change the editor and add the .bin path" $HOME/.zshrc` == "# Export to change the editor and add the .bin path" ]]; then
        # tee command permit to redirect into multiple files but print on stdout that's why I redirect stdout in /dev/null
        echo -e "\n# Export to change the editor and add the .bin path
export VISUAL=emacs
export EDITOR=\$VISUAL
export PATH=\$PATH:\$HOME/.bin" | tee -a $HOME/.bashrc $conf_dir/.zshrc > /dev/null
    fi
}

function create_alias()
{
    if [[ ! `grep "# Alias Section" $HOME/.zshrc` == "# Alias Section" ]]; then
        echo -e "\n# Alias Section" >> $conf_dir/.zshrc
        i=0
        first=0
        second=0
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
        echo -e "\n## Git tag permet de rajouter des numéros de versions à propos de certains commit
## Pour créer un tag sur le dernier commit :
## gtag <nom du tag>
## Si des tags ont été oublié pour certains commit, faites la commande suivante :
## gtaga <nom du tag> <nom du commit>
## Pour voir à quelles commits un tag est attribué, faites la commande suivante :
## git show <nom du tag>" | tee -a $HOME/.bashrc $conf_dir/.zshrc > /dev/null
    fi
}

function create_bin_home_directory()
{
    if [ ! -d $HOME/.bin ] ; then
        mkdir $HOME/.bin
    fi
}

function copy_to_be_executable()
{
    # basename permits to keep only the filename in a path for example :
    # test="/usr/bin/test.sh"
    # echo $(basename $test)
    # > test.sh
    if [ ! -f "$HOME/.bin/$(basename $1)" ] ; then
        cp $1 $HOME/.bin
        check_error
    fi
}

function use_create_alias()
{
    add_alias=0
    while [ $add_alias == 0 ]; do
        read -p "Souhaitez-vous créer des alias? (o/N): " answer
        if [[ "$answer" =~ $regex ]]; then
            ./create_alias
        else
            add_alias=1
        fi
    done
}

function generate_ssh_key()
{
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
}

function on_i3_config()
{
    if [[ -d $HOME/.config/i3 ]]; then
        read -p "Souhaitez-vous installer la configuration pour i3 ? (o/N): " answer
        if [[ "$answer" =~ $regex ]]; then
            cp -r $conf_dir/* $HOME/.config/i3
        fi
        check_error
    fi
}

echo "Début du script..."

echo "Mise à jour..."

# Mise à jour
upgrade
check_error

# Installation de différents paquets (voir conf/config)
install
check_error

# Installation de blih
blih_setup

# Setup d'emacs
emacs_setup

# Installation de Clion
clion_setup

# Installation de Discord
install_by_snap "discord"

# Add export to change the editor and add the .bin path
add_export

# Création des alias
create_alias

# Création du directory .bin dans le dossier HOME de l'utilisateur
create_bin_home_directory

# On rend le binaire create_alias executable de n'importe où
copy_to_be_executable "$APP_DIR/bin/create_alias"

# Utilisation du create_alias
use_create_alias

# Génération des clés ssh
generate_ssh_key

# Changement des droits sur poweroff et reboot pour pouvoir les utiliser sans sudo
sudo chmod +s /sbin/poweroff
check_error
sudo chmod +s /sbin/reboot
check_error

on_i3_config

read -p "Souhaitez-vous ouvrir Clion (pour créer les raccourcis) ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    ${HOME}/.clion/bin/clion.sh
fi

# Reset sudo, next time you will need a password
#sudo -k

# Copy du zshrc dans le home
cp $conf_dir/.zshrc $HOME/.zshrc

read -p "Souhaitez-vous supprimer le dossier de ce script ? (o/N): " answer
if [[ "$answer" =~ $regex ]]; then
    rm -rf $APP_DIR
fi

# Installation de oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
