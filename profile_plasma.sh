#! /bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

pkgs=(

# Base
base
base-devel
linux
linux-lts
linux-firmware
btrfs-progs
grub
efibootmgr
firewalld
networkmanager
xdg-user-dirs

# Shell
bash-completion

# CLI tools
bat
compsize
eza
devtools
fzf
gdb
git
git-delta
htop
less
net-tools
neovim
openssh
p7zip
pacman-contrib
pacutils
reflector
ripgrep
rsync
stow
tree
unrar
unzip
vim
xclip

# Audio
pipewire
pipewire-alsa
pipewire-audio
pipewire-jack
pipewire-pulse
pipewire-v4l2
pipewire-x11-bell
pipewire-zeroconf
wireplumber

# Terminal fonts
terminus-font

# Fonts
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
ttc-iosevka
ttf-fantasque-nerd
ttf-fantasque-sans-mono
ttf-fira-code
ttf-fira-sans
ttf-jetbrains-mono
ttf-liberation
ttf-roboto
ttf-roboto-mono
ttf-ubuntu-font-family

# Printing
cups
hplip
python-pyqt5

# Desktop
breeze5 # For Qt5 apps
plasma
sddm
xorg

# GUI Utilities
alacritty
ark
dolphin
filelight
firefox
firefox-i18n-fr
gwenview
kate
kcalc
kfind
kwalletmanager
libreoffice-fresh
libreoffice-fresh-fr
okteta
okular
partitionmanager
qpwgraph
skanlite
spectacle

# Other
hunspell
hunspell-fr
power-profiles-daemon

# System Backups
cronie
timeshift

# Programming
composer
jdk-openjdk
php
rustup

# VM & Containers
dnsmasq
docker
docker-compose
edk2-ovmf
iptables-nft
libvirt
openbsd-netcat
qemu-full
virt-manager

)

unpkgs=(

breeze-plymouth
discover
plasma-welcome
plymouth-kcm

)

units=(

cronie.service
cups.socket
docker.socket
firewalld.service
fstrim.timer
libvirtd.socket
NetworkManager.service
paccache.timer
power-profiles-daemon.service
reflector.timer
sddm.service

)

groups="wheel,docker"
mirrors_zone="France,Germany"
shell="/bin/bash"
