#!/bin/bash
VIDEO_DRIVER=xf86-video-intel libva-intel-driver

install_x(){
  yes | pacman -S $VIDEO_DRIVER
  pacman -S --noconfirm xorg-apps xorg-server xorg-xinit xterm
}

install_i3() {
  yes | pacman -S i3-wm i3status dmenu ttf-dejavu
  cat > ~/.xinitrc <<EOF
#!/bin/bash
exec i3
EOF

  cat >> /etc/profile  << EOL
if [[ "$(tty)" == '/dev/tty1' ]]; then
  exec startx
fi
EOL
}

install_x
install_i3
