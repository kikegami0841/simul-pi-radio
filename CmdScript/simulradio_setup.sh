#!/bin/sh

sudo apt update -y
sudo apt upgrade -y
sudo apt install python3-openpyxl -y

/opt/simulradio/bin/SimulRadio_StationList.py

#sudo apt remove python3-openpyxl -y



