#!/usr/bin/env bash

# Scrit de post installation sur Debian de la webradio V2 des CEMEA
# Francois Audirac <francois@webaf.net>
# Adapté CEMÉA Belges
# script sous licence GNU/GPL V3
# https://www.gnu.org/licenses/gpl.txt

# TODO : vérifier que le groupe audio existe
# Info : demander à l'utilisateur de s'ajouter au groupe audio



if [ $(whoami) == 'root' ]; then
    echo "Ne pas lancer ce script avec sudo, mais avec un utilisateur qui a les droits sudo"
    exit 0;
fi

monuser=$USER

# Dossier utilisateur
# Ménage
if [ -d "$HOME/.jackdrc" ]; then rm -rf "$HOME/.jackdrc"; fi
if [ -d "$HOME/.config/idjc" ]; then rm -rf "$HOME/.config/idjc"; fi
if [ -d "$HOME/.config/rncbc.org" ]; then rm -rf "$HOME/.config/rncbc.org"; fi

# Ajout des fichiers de config
TMPHOME=$(mktemp -d)
cd "$TMPHOME"
wget wget https://github.com/Papaul2/webradio/archive/master.zip
unzip main.zip
cp -R webradio-main/postinstall/config/.jackdrc "$HOME/"
cp -R webradio-main/postinstall/config/* "$HOME/.config/"
mkdir -p "$HOME/.local/share/applications"
mv webradio-main/postinstall/webradiov2.desktop "$HOME/.local/share/applications/"
chmod +x "$HOME/.local/share/applications/webradiov2.desktop"
cd -


# Ajout des dépots Librazik
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
wget https://download.tuxfamily.org/librazik/decepas/librazik-keyring_2_all.deb
wget https://download.tuxfamily.org/librazik/decepas/librazik-apt_2_all.deb
wget https://github.com/Papaul2/webradio/raw/master/postinstall/webradiov2.sh
wget https://github.com/Papaul2/webradio/raw/master/postinstall/webradiov2.desktop
wget https://github.com/Papaul2/webradio/raw/master/postinstall/config/conky.desktop
wget https://github.com/Papaul2/webradio/raw/master/postinstall/config/.conkyrc
wget https://github.com/Papaul2/webradio/raw/master/postinstall/config/icecast.xml


# On passe root !
echo -e "\e[31mEntrez votre mot de passe pour installation de paquets\e[0m"
resultat=$(sudo echo "Installation en cours")
# 2. Ajout des paquets de base : basse latence, qjackctl, idjc

if [ $(sudo whoami) != 'root' ]; then
    echo "Désolé, il faut utiliser un utilisateur qui a les droits sudo"
    echo "Modifiez ces droits en l'ajoutant au groupe sudo ou changez d'utilisateur"
    exit 0;
fi

sudo adduser $monuser audio
sudo sh -c "dpkg -i librazik-keyring_2_all.deb && \
dpkg -i librazik-apt_2_all.deb && \
rm librazik-keyring_2_all.deb && \
rm librazik-apt_2_all.deb && \
apt-get update && apt-get --yes upgrade && \
apt-get install --reinstall --yes idjc qjackctl linux-image-4.9.0-8-lzk-bl-amd64 unzip yad icecast2 && \
chmod +x webradiov2.sh && \
mv webradiov2.sh /usr/local/bin/ && \
chmod +x conky.desktop && \
mv .conkyrc $HOME/ && \
mv conky.desktop $HOME/.config/autostart/ && \
mkdir -p -v /usr/share/webradio/images && \
cp -v $TMPHOME/webradio-main/postinstall/config/images/* /usr/share/webradio/images/ && \
mkdir -p -v /usr/share/wallpapers/webradio && \
cp -v $TMPHOME/webradio-main/postinstall/config/wallpapers/* /usr/share/wallpapers/webradio/ 
cp -v $TMPHOME/webradio-main/postinstall/config/icecast.xml /etc/icecast2/ 
cp -v $HOME/.local/share/applications/webradiov2.desktop $HOME/Bureau/"

# Nettoyage
cd -
rm -rf "$TMPDIR"
rm -rf "$TMPHOME"
rm -f ./installwrv2.sh

# Ajout d'une interface pour le canal simplifié
echo "Merci de redémarrer votre PC (pour bénéficier du noyau basse latence"
echo "Un lanceur \"CEMEA Webradio\" a été ajouté dans le menu !"

# Ajout de la documentation

#  Ajout du fond d'écran
dconf write /org/mate/desktop/background/picture-filename "'/usr/share/wallpapers/webradio/webradio_fond.png'"
