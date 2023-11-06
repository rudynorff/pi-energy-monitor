#!/bin/bash

# INSTALL EVERYTHING THAT IS NEEDED
sudo apt update && sudo apt upgrade
sudo apt install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
# TODO INSTALL cargo/rustc/etc

sudo touch /etc/mosquitto/conf.d/local.conf
sudo echo "listener 1883" >> /etc/mosquitto/conf.d/local.conf
sudo echo "allow_anonymous true" >> /etc/mosquitto/conf.d/local.conf
sudo systemctl restart mosquitto

# MAKE THE PI HAVE A STATIC IP ADDRESS ON ITS ETHERNET INTERFACE
sudo echo "interface en0" >> /etc/dhcpcd.conf
sudo echo "static ip_address=192.168.178.122/24" >> /etc/dhcpcd.conf
sudo echo "static routers=192.168.178.1" >> /etc/dhcpcd.conf
sudo echo "static domain_name_servers=192.168.178.1 1.1.1.1 8.8.8.8 fd51:42f8:caae:d92e::1" >> /etc/dhcpcd.conf

# TODO COMPILE mqtt-eporter
# TODO ADD mqtt-eporter bin to cron that executes at boot
# TODO ADD shell script to cron that grabs sqlite every 5 minutes and uses gnuplot (or alike)

echo "Your system should be ready. A restart is required."
read -p "Press enter to continue"
sudo shutdown -r now