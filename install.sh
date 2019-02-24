#!/bin/bash

DISK='/dev/sda'

config_partitions() {
  local boot_size=256
  local memory=vmstat -s -S M | grep 'total memory' | tr -dc '0-9'
  local memory_addr=$(($memory + $boot_size))M

  echo "Formatting disk"
  parted -s "$DISK" \
    mklabel msdos \
    mkpart primary ext2 1 "$boot_size"M \
    mkpart primary ext4 $memory_addr 100% \
    mkpart primary linux-swap "$boot_size"M  $memory_addr \
    set 1 boot on \
    set 2 LVM on \
    set 3 SWAP on
}

format_disk() {
  local boot_dev="$DRIVE"1
  local lvm_dev="$DRIVE"2
  local swap_dev="$DRIVE"3

  config_partitions

  mkfs.ext2 -L boot "$boot_dev"
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

config_system() {
  genfstab -U /mnt >> /mnt/etc/fstab
  arch-chroot /mnt
}

install_arch() {
  format_disk
  install_base
  config_system
}

install_arch
