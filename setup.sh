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

set -e
clear

# Import profile file
source ./profile.sh

#
# FUNCTIONS
#

select_disk_part_dialog() {
    disks=$(lsblk -lp -o name,type | grep /dev)
    dialog --stdout --title "$1" --menu "" 0 0 0 $disks;
}

password_dialog() {
    dialog --stdout --title "$1" --passwordbox "" 0 0
}

input_dialog() {
    dialog --stdout --title "$1" --inputbox "" 0 0
}

select_cpu_ucode() {
    dialog --stdout --title "" --menu "" 0 0 0 "Intel" "Install Intel microcode" "AMD" "Install AMD microcode" "None" "Install nothing"
}

end_dialog() {
    dialog --stdout --title "" --msgbox "INSTALLATION COMPLETED" 5 26
}

patch_pacman_config() {
    sed -i "s/#Color/Color\nILoveCandy/g" $1
    sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" $1
    sed -i "s/#ParallelDownloads.*/ParallelDownloads = 5/g" $1
}

#
# LIVE OS PREPARATION
#

# Patch local pacman configuration
patch_pacman_config /etc/pacman.conf

# Sort mirrors
reflector --country $mirrors_zone --save /etc/pacman.d/mirrorlist

# Install setup dependencies
pacman --noconfirm -Sy archlinux-keyring dialog terminus-font

# Set font
setfont ter-v16n

#
# DIALOGS
#

root_partition=$(select_disk_part_dialog " Root partition ")
efi_partition=$(select_disk_part_dialog " EFI partition ")
grub_disk=$(select_disk_part_dialog " GRUB device ")
disk_password=$(password_dialog " Disk password ")
hostname=$(input_dialog " Hostname ")
root_password=$(password_dialog " Root password ")
user_name=$(input_dialog " User name ")
user_display_name=$(input_dialog " User display name ")
user_password=$(password_dialog " User password ")
cpu_ucode=$(select_cpu_ucode)

if [ $cpu_ucode = "Intel" ]; then
    pkgs+=("intel-ucode")
fi

if [ $cpu_ucode = "AMD" ]; then
    pkgs+=("amd-ucode")
fi

clear

#
# PREPARATION
#

# Update date and time
timedatectl set-timezone Europe/Paris
timedatectl set-ntp true

# Disk formatting and mounting
mkfs.vfat -F32 $efi_partition
echo -n "$disk_password" | cryptsetup luksFormat $root_partition -
echo -n "$disk_password" | cryptsetup open $root_partition filesystem -
mkfs.btrfs -L "Arch Linux" /dev/mapper/filesystem
mount /dev/mapper/filesystem /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
umount /mnt
mount -o compress-force=zstd,subvol=@ /dev/mapper/filesystem /mnt
mkdir /mnt/boot /mnt/home /mnt/swap
mount -o compress-force=zstd,subvol=@home /dev/mapper/filesystem /mnt/home
mount -o compress-force=zstd,subvol=@swap /dev/mapper/filesystem /mnt/swap
mount $efi_partition /mnt/boot

# Swapfile
btrfs filesystem mkswapfile --size $(cat /proc/meminfo | grep MemTotal | awk '{print $2}')K /mnt/swap/swapfile
swapon /mnt/swap/swapfile

#
# INSTALLATION
#

# Installation bootstrap
pacstrap -K /mnt ${pkgs[*]}

#
# SYSTEM CONFIGURATION
#

# Generate filesystem table file (/etc/fstab)
genfstab -U /mnt > /mnt/etc/fstab

# Pacman configuration
patch_pacman_config /mnt/etc/pacman.conf

# Host name
echo "$hostname" > /mnt/etc/hostname

# Hosts
echo "127.0.0.1    localhost" > /mnt/etc/hosts
echo "::1    localhost" >> /mnt/etc/hosts

# Console configuration
echo "KEYMAP=fr" > /mnt/etc/vconsole.conf
echo "FONT=ter-v16n" >> /mnt/etc/vconsole.conf

# Locale (Language and time)
echo "LANG=fr_FR.UTF-8" > /mnt/etc/locale.conf
echo "fr_FR.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --utc --systohc

# Swappiness
echo "vm.swappiness = 10" > /mnt/etc/sysctl.d/99-swappiness.conf

# X11 Keyboard
mkdir -p /mnt/etc/X11/xorg.conf.d
echo "Section \"InputClass\"" > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
echo "    Identifier \"system-keyboard\"" >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
echo "    MatchIsKeyboard \"on\"" >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
echo "    Option \"XkbLayout\" \"fr\"" >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
echo "    Option \"XkbOptions\" \"caps:escape_shifted_capslock\"" >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
echo "EndSection" >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf

# Reflector
echo "--country " $mirrors_zone > /mnt/etc/xdg/reflector/reflector.conf
echo "--save /etc/pacman.d/mirrorlist" >> /mnt/etc/xdg/reflector/reflector.conf

# Docker
mkdir -p /mnt/etc/docker
echo "{" > /mnt/etc/docker/daemon.json
echo "    \"storage-driver\": \"overlay2\"" >> /mnt/etc/docker/daemon.json
echo "}" >> /mnt/etc/docker/daemon.json

# SystemD units to enable
arch-chroot /mnt systemctl enable ${units[*]}

#
# USER AND ROOT CONFIGURATION
#

# Root password
echo -n -e "$root_password\n$root_password" | arch-chroot /mnt passwd root

# User creation
arch-chroot /mnt useradd -m -g users -G $groups -s $shell -c "$user_display_name" $user_name
echo -n -e "$user_password\n$user_password" | arch-chroot /mnt passwd $user_name
echo "$user_name ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers

# User profile
echo "source ~/.profile" > /mnt/etc/profile.d/user_profile.sh
chmod +x /mnt/etc/profile.d/user_profile.sh

#
# BOOT CONFIGURATION
#

# Initramfs configuration
sed -i "s/HOOKS=(.*)/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck resume)/g" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

# Grub configuration
root_partition_uuid=$(lsblk -lp -o name,uuid | grep $root_partition | awk '{print $2}')
filesystem_uuid=$(lsblk -lp -o name,uuid | grep /dev/mapper/filesystem | awk '{print $2}')
resume_offset=$(btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile)

sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/g" /mnt/etc/default/grub
sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/g" /mnt/etc/default/grub
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 cryptdevice=UUID=${root_partition_uuid}:filesystem resume=UUID=${filesystem_uuid} resume_offset=${resume_offset}\"/g" /mnt/etc/default/grub
sed -i "s/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/g" /mnt/etc/default/grub
sed -i "s/#GRUB_TERMINAL_OUTPUT/GRUB_TERMINAL_OUTPUT/g" /mnt/etc/default/grub
sed -i "s/#GRUB_SAVEDEFAULT/GRUB_SAVEDEFAULT/g" /mnt/etc/default/grub
sed -i "s/#GRUB_DISABLE_SUBMENU/GRUB_DISABLE_SUBMENU/g" /mnt/etc/default/grub

arch-chroot /mnt grub-install $grub_disk --efi-directory /boot --bootloader-id "Arch Linux"
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

#
# AUR INSTALLATION
#

# Compilation optimisations
sed -i "s/CFLAGS=\"-march=.* -mtune=.* -O2/CFLAGS=\"-march=native -O3/g" /mnt/etc/makepkg.conf
sed -i "s/LDFLAGS=\"-Wl,-O1/LDFLAGS=\"-Wl,-O3/g" /mnt/etc/makepkg.conf
sed -i "s/#RUSTFLAGS=\".*\"/RUSTFLAGS=\"-C opt-level=3 -C target-cpu=native\"/g" /mnt/etc/makepkg.conf
sed -i "s/#MAKEFLAGS=\".*\"/MAKEFLAGS=\"-j$(nproc)\"/g" /mnt/etc/makepkg.conf

# Install paru
arch-chroot /mnt su -c "rustup default stable" $user_name
arch-chroot /mnt su -c "cd /home/$user_name;git clone https://aur.archlinux.org/paru" $user_name
arch-chroot /mnt su -c "cd /home/$user_name/paru;makepkg --noconfirm" $user_name
arch-chroot /mnt pacman --noconfirm -U /home/$user_name/paru/$(ls /mnt/home/$user_name/paru | grep "paru.*\.pkg.tar.zst" | grep -v ".*debug.*")
rm -r /mnt/home/$user_name/paru

# Configure paru
sed -i "s/#BottomUp/BottomUp/g" /mnt/etc/paru.conf
sed -i "s/#NewsOnUpgrade/NewsOnUpgrade/g" /mnt/etc/paru.conf

#
# CLEANING
#

arch-chroot /mnt paru --noconfirm -Runs ${unpkgs[*]}
arch-chroot /mnt paccache -u -r -k 0

#
# END
#

end_dialog
clear
