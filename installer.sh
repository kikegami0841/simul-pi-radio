#!/bin/sh
#https://downloads.raspberrypi.org/imager/
#win 2.0.10 CUI 起動 32bitのCUI版(LITE) imageを使う
#前処理 Raspi ImagerでmicroSDカードを作りWi-Fiが接続、SSHでログインできるアカウント作成済み
#前処理 sudo apt update, sudo apt upgrade -y は実行済み
#====
#最初に、githubから取ってくる
#GUIの要らないものを削除、apt grade
 sudo apt remove cups-server-common -y
 sudo apt remove cups-daemon -y
 sudo apt remove cups-common -y
 sudo apt remove firefox -y
 sudo apt autoremove -y
#sudo apt update
#sudo apt upgrade -y
#sudo apt install git -y

#=====
#=====Liteグレードを選択したら、pipe wireが入っていないので以下を追加

grep "hifiberry-dac" /boot/firmware/config.txt
if [ $? -eq "0" ]; then
  echo "DAC Exist"
else
sudo /usr/bin/bash -c "cat <<EOF >> /boot/firmware/config.txt
 dtparam=i2s=on
# dtparam=audio=off
 dtoverlay=hifiberry-dac
 force_eeprom_read=0
EOF
"
fi

grep "snd_soc_hifiberry_dac" /etc/modules
if [ $? -eq "0" ]; then
  echo "snd_ Exist"
else
sudo /usr/bin/bash -c "cat <<EOF >> /etc/modules
 snd_soc_hifiberry_dac
EOF
"
fi

grep "pcm.!default" $HOME/.asound.rc
if [ $? -eq "0" ]; then
  echo "DAC Exist"
else
cat <<EOF >> $HOME/.asound.rc
 pcm.!default {
        type hw
        card 0
 }
 ctl.!default {
        type hw
        card 0
 }
EOF
fi

grep audio /etc/group | grep `whoami`
if [ $? -eq "0" ]; then
  echo "Exist"
else
  sudo adduser `whoami` audio
fi
grep bluetooth /etc/group | grep `whoami`
if [ $? -eq "0" ]; then
  echo "Exist"
else
  sudo adduser `whoami` bluetooth
fi

# pw-top で OutputがAlsa関連(pcm5101a)に出ているか確認
#  音出し
# DACの端子をHighにする　38pinに結線した場合
# raspi-gpio set 20 op pu dh
#aplay /usr/share/sounds/alsa/Front_Center.wav

#Python.js 
sudo apt install libpython3.13-dev -y
sudo apt install pip -y
sudo apt install python3-setuptools -y
sudo apt install python3-gpiozero -y
sudo apt install python3-requests-unixsocket -y
sudo apt install python3-websocket -y
sudo apt install python3-pexpect -y
sudo apt install curl jq libxml2-utils -y
sudo apt install nodejs -y
sudo apt install npm -y
sudo apt install python3-dbus -y
sudo apt install ffmpeg -y

#AUDUIO
#RPi ImagerのオプションのサービスタブでSSHのチェックを忘れずに入れる
sudo apt install pipewire -y
sudo apt install pipewire-pulse -y
sudo apt install pipewire-audio-client-libraries -y
sudo apt install pulseaudio pulseaudio-module-zeroconf -y

#Network/Others
sudo apt install iptables -y
sudo apt install network-manager -y
sudo apt install raspi-utils-core -y

grep pipewire /etc/group
if [ $? -eq "0" ]; then
  echo "Exist"
else
 sudo addgroup --gid 111 pipewire
fi

sudo usermod -aG pipewire `whoami`
sudo usermod -aG audio `whoami`
grep XDG_CONFIG_HOME ~/.bashrc
if [ $? -eq "0" ]; then
  echo "Exist"
else
cat <<EOF >> ~/.bashrc
 export XDG_CONFIG_HOME=$HOME/.config
EOF
fi

cd ~/
mkdir src
cd src
#simul-pi-radio body
git clone https://github.com/kikegami0841/simul-pi-radio.git

# radish-play.sh
git clone https://github.com/kikegami0841/radish-play
# rec_wss.py
git clone https://github.com/je3kmz/jcba

cd ~/
ln -sfn $HOME/src/simul-pi-radio SimulRadio
sudo mkdir /opt/simulradio
sudo chown `whoami`:`whoami` /opt/simulradio
ln -sfn $HOME/src/simul-pi-radio/CmdScript /opt/simulradio/bin

ln -sfn /opt/simulradio/bin/dotconfig_pipewire $HOME/.config/pipewire
ln -sfn /opt/simulradio/bin/dotconfig_wireplumber $HOME/.config/wireplumber

cd /opt/simulradio/bin
ln -sfn $HOME/src/radish-play/radish-play.sh
chmod +x $HOME/src/jcba/rec_wss.py
ln -sfn $HOME/src/jcba/rec_wss.py

#各局再生コマンドの自動生成
cd /opt/simulradio/bin/
sh simulradio_setup.sh
cd /opt/simulradio/bin/
ln -sfn /opt/simulradio/bin/SimulRadio_StationList.xlsx $HOME/SimulRadio_StationList.xlsx

mkdir ~/.config
cd ~/.config
mkdir systemd
cd systemd
ln -sfn /opt/simulradio/bin/dotconfig_systemd_user/ $HOME/.config/systemd/user

cd ~/.config/systemd/user

 systemctl --user enable simulradio.service
 systemctl --user start  simulradio.service
# systemctl --user status simulradio.service

#Web Server設定
 cd ~/SimulRadio/
 ln -sfn node_modules/.package-lock.json package-lock.json
 npm install

#wifi起動後にsystemd --userのサービスを起動する設定
 sudo loginctl enable-linger `whoami`

#GUI -> CUI
#  # System Oprions > Boot / Auto Login > Console
#自動でRebootする 最後に移動 (sudo systemctl set-default multi-user.target)
sudo systemctl set-default multi-user.target

#確認
sudo systemctl get-default

#rootfs ROM化 Enable
sudo raspi-config nonint enable_overlayfs
#sudo systemctl reboot
#rootfs ROM化 Disable 
# sudo raspi-config nonint disable_overlayfs
#状態は df の / mountで確認
