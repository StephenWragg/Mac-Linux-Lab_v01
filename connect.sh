#!/bin/sh

sudo dpkg -i bcmwl-kernel-source_6.30.223.271+bdcom-0ubuntu1~1.1_amd64.deb dkms_2.2.0.3-2ubuntu11.3_all.deb
sudo cp wpa_supplicant.conf /etc/
sudo cp interfaces /etc/network/

