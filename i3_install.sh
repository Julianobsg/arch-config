#!/bin/bash
VIDEO_DRIVER=xf86-video-intel libva-intel-driver

install_x(){
  yes | sudo pacman -S $VIDEO_DRIVER
  sudo pacman -S --noconfirm xorg-apps xorg-server xorg-xinit xterm
}

install_lightdm() {
  yes | sudo pacman -S lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service -f
}

install_yay() {
  git clone https://aur.archlinux.org/yay.git
  cd yay
  yes | makepkg -si
  cd ..
  rm -rf yay
}

install_i3() {
  yes | sudo pacman -S i3-wm i3status dmenu ttf-dejavu ttf-inconsolata dunst libnotify xdg-utils gnome-icon-theme

  install_lightdm

  yes | sudo pacman -S rxvt-unicode git vim ranger
  install_yay
  yay --noconfirm -S google-chrome urxvt-tabbedex ttf-meslo ttf-mensch otf-inconsolata-dz-powerline
}

install_x
install_i3
