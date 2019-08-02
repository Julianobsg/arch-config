#! /usr/bin/bash
# Sets right perspective when monitor is plugged in
# Needed by udev rule /etc/udev/rules.d/95-hotplug-monitor
export DISPLAY=:0
export XAUTHORITY=/home/juliano/.Xauthority

function connect(){
    xrandr --output HDMI1 --preferred --primary --left-of eDP1 --output HDMI1 --preferred
}

function disconnect(){
      xrandr --output HDMI1 --off
}

xrandr | grep "HDMI1 connected" &> /dev/null && connect || disconnect
