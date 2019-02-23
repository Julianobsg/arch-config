#!/bin/bash

DISK='/dev/sda'

format_disk() {
  echo "Formatting disk"
  parted -s "$DISK" \
    mklabel msdos \
    mkpart primary ext2 1 100M \
    mkpart primary ext2 100M 100% \
    set 1 boot on \
    set 2 LVM on
}

install_arch() {
  format_disk
}

install_arch
