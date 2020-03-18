#!/usr/bin/env bash

user=$(logname)
tmp_dir="/tmp/auto-install/"
install="apt install -y"
update="apt update -y"

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root type: sudo ./installscript" 
	exit 1
fi

mkdir -p "${tmp_dir}"
cd "${tmp_dir}"

$update
apt upgrade -y

if ! [ -e /usr/lib/snapd ] ; then
	$install snapd
fi

$install mlocate moreutils htop curl wget jq unzip git gnome-tweaks xclip

$install ubuntu-restricted-extras

$install firefox

#add-apt-repository -y ppa:gnome-terminator/xenial
#$update
#$install terminator

$install python3-dev python3-pip build-essential libssl-dev libffi-dev python3-setuptools

$install gedit

gpasswd -a $user input
libinput_gestures_dir="/home/${user}/.libinput-gestures"
$install xdotool wmctrl libinput-tools
git clone https://github.com/bulletmark/libinput-gestures.git "${libinput_gestures_dir}"
cd "${libinput_gestures_dir}"
sudo make install
libinput-gestures-setup autostart
libinput-gestures-setup start
cd "${tmp_dir}"

$install zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

$update
apt autoremove -y --purge

rm -rf "${tmp_dir}"
updatedb
