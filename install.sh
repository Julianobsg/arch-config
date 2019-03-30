#!/bin/bash

DISK='/dev/sda'

# System configuration variables
TIMEZONE='America/Sao_Paulo'
LOCALE='en_US.UTF-8 UTF-8\n pt_BR.UTF-8 UTF-8'
USERNAME=$2
PASSWORD=$3
HOSTNAME=$4

is_efi() {
  [ -d '/sys/firmware/efi/efivars' ]
}

user_configurations() {
  echo "Choose your user name"
  read USERNAME
  echo "Set your root password"
  read -s PASSWORD
  echo "Set your hostname:"
  read HOSTNAME
}

config_partitions() {
  local boot_size=256
  local memory=$(vmstat -s -S M | grep 'total memory' | tr -dc '0-9')
  local memory_addr=$(($memory + $boot_size))M

  echo "Formatting disk"
  parted -s "$DISK" \
    mklabel msdos \
    mkpart primary ext4 $memory_addr 100% \
    mkpart primary linux-swap "$boot_size"M  $memory_addr \
    set 2 LVM on \
    set 3 LVM on
}

format_disk() {
  local boot_dev="$DISK"1
  local lvm_dev="$DISK"2
  local swap_dev="$DISK"3

  if is_efi
  then
    parted -s "$DISK"
      mkpart primary fat32 1 "$boot_size"M \
      set 1 esp on
    mkfs.fat -F32 "$boot_dev"
  else
    parted -s "$DISK"
      mkpart primary ext2 1 "$boot_size"M
      set 1 bios_grub on
    mkfs.ext2 -L boot "$boot_dev"
  fi

  config_partitions

  mkfs.ext4 -L root "$lvm_dev"
  mkswap $swap_dev
  swapon $swap_dev

  mount $lvm_dev /mnt
  mkdir /mnt/boot
  mount $boot_dev /mnt/boot
}

install_base() {
  pacstrap /mnt base base-devel
}

config_locale() {
  echo  $LOCALE >> /etc/locale.gen
  locale-gen
  cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF
}

set_hostname() {
  cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1  localhost
127.0.1.1 $HOSTNAME.localdomain	$HOSTNAME
EOF
}

create_user() {
  echo "Creating user"
  groupadd sudo
  useradd -m -s /bin/zsh -G root,sudo "$USERNAME"
  echo -en "$PASSWORD\n$PASSWORD" | passwd "$USERNAME"
  echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers
}

install_tools() {
  local tools='zsh wget htop display wpa_supplicant'
  yes | pacman -S $tools
}

config_system() {
  echo "Start system configurations"
  ln -sT "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
  hwclock --systohc
  config_locale
  set_hostname
  echo -en "$PASSWORD\n$PASSWORD" | passwd
  create_user
  install_tools
}

install_grub() {
  yes | pacman -S grub
  if is_efi
  then
    grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=arch
  else
    grub-install --target=i386-pc $DISK
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
}

install_i3() {
  echo "Installing i3 and dependencies"
  sh -c "`curl -fsSL https://raw.githubusercontent.com/Julianobsg/arch-config/master/i3_install.sh`"
}

finish_installation() {
  install_grub
  rm /install.sh
  exit
  umount /mnt/boot
  umount /mnt
  echo "Config finished, please boot your system."
}

install_arch() {
  if [ -z "$USERNAME" ]
  then
    user_configurations
  fi

  if [ "$1" == "config" ]
  then
    config_system
    install_i3
    finish_installation
  else
    format_disk
    install_base
    genfstab -U /mnt >> /mnt/etc/fstab
    cp $0 /mnt/install.sh
    arch-chroot /mnt ./install.sh config $USERNAME $PASSWORD $HOSTNAME
  fi
}

install_arch $1 $2 $3 $4
