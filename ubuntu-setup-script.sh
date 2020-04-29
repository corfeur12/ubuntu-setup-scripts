#!/usr/bin/env bash

set -e

user=$(logname)
home=$HOME
script_name=`basename "$0"`
tmp_dir="/tmp/auto-install/"
install="sudo apt install -y"
update="sudo apt update -y"

# check if script run via sudo but not as su
if [[ -z $SUDO_USER || $EUID -eq 0 ]]; then
	echo "This script must be run by root type: sudo -u ${user} ./${script_name}"
	exit 1
fi

mkdir -p "${tmp_dir}"
cd "${tmp_dir}"

$update
sudo apt upgrade -y

if ! [ -e /usr/lib/snapd ] ; then
	$install snapd
fi

$install locate moreutils htop curl wget jq unzip git gnome-tweaks xclip

$install zsh
# TODO: check this works when run as su
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

$install tmux
$install fonts-powerline
git clone https://github.com/mohitt/tmux-config.git
# TODO: check this works when run as su
./tmux-config/install.sh
rm -rf ./tmux-config
echo "
PATH="$PATH:$HOME/.local/bin/"

tabs 4

if command -v tmux &> /dev/null && [ -n "$PS1"  ] && [[ ! "$TERM" =~ screen  ]] && [[ ! "$TERM" =~ tmux  ]] && [ -z "$TMUX"  ]; then
    attach_session=$(tmux 2> /dev/null ls -F '#{session_attached} #{?#{==:#{session_last_attached},},1,#{session_last_attached}} #{session_id}' | awk '/^0/ { if ([ > t) { t = [; s = { } }; END { if (s) printf "%s", s  }')
    if [ -n "$attach_session"   ]; then
        exec tmux attach -t "$attach_session"
    else
        exec tmux
    fi
fi" >> "${home}/.zshrc"

$install ubuntu-restricted-extras

$install firefox

$install python3-dev python3-pip build-essential libssl-dev libffi-dev python3-setuptools

$install gedit

# TODO: check if device needs this or not
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
sudo apt autoremove -y --purge

rm -rf "${tmp_dir}"
sudo updatedb
