#!/bin/bash

initializeNetwork(){
    # Make the dhcpcd binary setuid during arch installation
    # Then only this sequence will run
    # If network card is down or powered off
    sudo rfkill unblock all # Maybe you want to include wirelesscard here instead of all using rfkill list
    ip link set wlan0 up


    # Configure Internet Connection
    iwctl station wlan0 connect Needle
    dhcpcd wlan0
}
initializePulseAudio(){
    pulseaudio -D
}

initializeMiscServices(){
    # Please save my eyes
    redshift -x
    redshift -O 3000

    # Restore my waifu
    nitrogen --restore

    # Start compositor
    picom --experimental-backend -b

    dwmblocks &

    xbindkeys -f ~/.xbindkeysrc 

    xmodmap .Xmodmap 

    dunst &

    # For flameshot daemon
    flameshot &

}
initializeMiscServices &

# Start WM
while :; do
	dwm 2> ~/.dwm.log
done
