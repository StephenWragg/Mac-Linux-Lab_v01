#!/bin/sh

sudo cp wpa_supplicant.conf /etc/
sudo cp interfaces /etc/network/
sudo cp 50-auto-guest.conf /usr/share/lightdm/lightdm.conf.d/

sudo cp syspref.js /etc/firefox/syspref.js

sudo apt-get install -y numlockx
sudo sed -i 's|^exit 0.*$|# Numlock enable\n[ -x /usr/bin/numlockx ] \&\& numlockx on\n\nexit 0|' /etc/rc.local

sudo cp usb-audio-select.sh /usr/bin/
sudo chmod +rx /usr/bin/usb-audio-select.sh

sudo apt-get install -y msttcorefonts

sudo sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y ubuntu-restricted-extras

sudo cp CASecureBrowser9.2-2016-10-02-x86_64.tar.bz2 /opt/
sudo tar -xjf /opt/CASecureBrowser9.2-2016-10-02-x86_64.tar.bz2 -C /opt
sudo /opt/CASecureBrowser/install-icon.sh
sudo sed -i '/exit 0/igsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-hide-mode 1\ngsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ reveal-trigger 1' /opt/CASecureBrowser/CASecureBrowser.sh

sudo apt-get purge -y apport thunderbird libreoffice-*
sudo rsync -av skel /etc/guest-session/

