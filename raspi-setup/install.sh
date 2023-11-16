#!/bin/bash

# INSTALL EVERYTHING THAT IS NEEDED
sudo apt update && sudo apt upgrade
sudo apt install -y mosquitto mosquitto-clients
sudo apt install sqlite3

echo "Making the Pi have a static IP address for the ethernet interface"
sudo echo "interface en0" >> /etc/dhcpcd.conf
sudo echo "static ip_address=192.168.178.144/24" >> /etc/dhcpcd.conf
sudo echo "static routers=192.168.178.1" >> /etc/dhcpcd.conf
sudo echo "static domain_name_servers=192.168.178.1 1.1.1.1 8.8.8.8 fd51:42f8:caae:d92e::1" >> /etc/dhcpcd.conf

echo "Enabling MosQuiTTo on system start"
sudo touch /etc/mosquitto/conf.d/local.conf
sudo echo "listener 1883" >> /etc/mosquitto/conf.d/local.conf
sudo echo "allow_anonymous true" >> /etc/mosquitto/conf.d/local.conf


echo "Compile and install mqtt-exporter"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
git clone https://github.com/rudynorff/pi-energy-monitor.git
cd ./pi-energy-monitor/mqtt-exporter/
cargo build --release
sudo cp ./target/release/mqtt-exporter /usr/bin
cd ../../raspi-setup/
sudo cp ./mqtt-exporter.service /etc/systemd/system/

echo "Install and start plotter that creates graphs and shows them as a website"
cd plotter-service/
sudo cp ./template.html /
sudo cp ./plotter.sh /usr/bin/
sudo cp ./plotter.service /etc/systemd/system/

echo "Start services without restarting the system"
sudo systemctl enable mosquitto
sudo systemctl enable mqtt-exporter.service
sudo systemctl enable plotter.service
sudo systemctl daemon-reload
sudo systemctl start mosquitto
sudo systemctl start mqtt-exporter.service
sudo systemctl start plotter.service

