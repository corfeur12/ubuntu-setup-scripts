#!/usr/bin/env bash

user=$(logname)
home=$HOME
script_name=`basename "$0"`
tmp_dir="/tmp/auto-install/"
install="apt install -y"
update="apt update -y"

# check if script run via sudo but not as su
if [[ -z $SUDO_USER || $EUID -eq 0 ]]; then
	echo "This script must be run by root type: sudo -u ${user} ./${script_name}"
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

$install zsh
chsh -s $(which zsh)
# TODO: check this works when run as su
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

$install tmux
$install fonts-powerline
git clone https://github.com/samoshkin/tmux-config.git
# TODO: check this works when run as su
./tmux-config/install.sh
rm -rf ./tmux-config
echo "
if [[ ! $TERM =~ screen ]]; then
    exec tmux
fi" >> "${home}/.zshrc"

$install ubuntu-restricted-extras

$install firefox

$install python3-dev python3-pip build-essential libssl-dev libffi-dev python3-setuptools

$install gedit

gpasswd -a $user input
libinput_gestures_dir="${home}/.libinput-gestures"
$install xdotool wmctrl libinput-tools
git clone https://github.com/bulletmark/libinput-gestures.git "${libinput_gestures_dir}"
cd "${libinput_gestures_dir}"
sudo make install
libinput-gestures-setup autostart
libinput-gestures-setup start
cd "${tmp_dir}"
echo "
alias libinput-gestures-update='cd ~/.libinput-gestures && git pull && sudo make install && libinput-gestures-setup restart'" >> "${home}/.zshrc"

$update
apt autoremove -y --purge

rm -rf "${tmp_dir}"
updatedb
