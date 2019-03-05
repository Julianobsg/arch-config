#!/bin/bash
VIDEO_DRIVER=xf86-video-intel libva-intel-driver

install_x(){
  yes | pacman -S $VIDEO_DRIVER
  pacman -S --noconfirm xorg-apps xorg-server xorg-xinit xterm
}

install_lightdm() {
  yes | pacman -S lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service -f
}

install_i3() {
  yes | pacman -S i3-wm i3status dmenu ttf-dejavu

  install_lightdm

  yes | pacman -S rxvt-unicode
}

install_x
install_i3
