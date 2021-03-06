#!/bin/bash
VIDEO_DRIVER='xf86-video-intel libva-intel-driver'

install_x(){
  yes | sudo -i pacman -S $VIDEO_DRIVER
  yes | sudo -i pacman -S --noconfirm xorg-apps xorg-server xorg-xinit xterm
}

install_lightdm() {
  yes | sudo -i pacman -S lightdm lightdm-gtk-greeter
  yes | sudo -i systemctl enable lightdm.service -f
}

install_yay() {
  cd ~/
  git clone https://aur.archlinux.org/yay.git
  cd yay
  yes | makepkg -si
  cd ..
  rm -rf yay
  cd /
}

install_i3() {
  yes | sudo -i pacman -S i3-wm i3status dmenu ttf-dejavu ttf-inconsolata dunst libnotify xdg-utils gnome-icon-theme

  install_lightdm

  yes | sudo -i pacman -S git vim ranger alacritty
  yes | sudo -i pacman -S pulseaudio pulseaudio-alsa pavucontrol
  yes | sudo -i pacman -S pulseaudio-bluetooth bluez bluez-utils blueman
  install_yay
  yay --noconfirm -S google-chrome ttf-meslo ttf-mensch otf-inconsolata-dz-powerline wpa-cute

  yes | sudo -i pacman -S dialog stow openssh
  yay --noconfirm -S i3lock-fancy polybar
}

install_x
install_i3
