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
devtools
fzf
git
htop
less
net-tools
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
gnome-keyring
gvfs
lightdm-gtk-greeter
lightdm-gtk-greeter-settings
power-profiles-daemon
xfce4
xfce4-goodies
xorg

# GUI Utilities
catfish
engrampa
firefox
firefox-i18n-fr
gnome-disk-utility
hunspell
hunspell-fr
network-manager-applet
pavucontrol
qpwgraph
ristretto
seahorse
simple-scan
xed
xreader

# System Backups
cronie
timeshift

# Programming
rustup

)

unpkgs=(

mousepad
parole
xfburn
xfce4-dict

)

units=(

cronie.service
cups.socket
firewalld.service
fstrim.timer
lightdm.service
NetworkManager.service
paccache.timer
power-profiles-daemon.service
reflector.service

)

groups="wheel"
mirrors_zone="France,Germany"
shell="/bin/bash"
