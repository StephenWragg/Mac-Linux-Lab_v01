#!/bin/bash

# Automatically select USB sound devices 
# Copyright (C) 2013 Stephen Ostermiller
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, 
# Boston, MA  02110-1301, USA.

if [ "$1" = "--install" ]
then
    if [ $EUID -ne 0 ]
    then
        echo "Error you are not the root user."
        echo "Run this install as root (or use sudo)"
        exit 1
    fi
    if [ ! `which play` ]
    then
         apt-get -y install sox
    fi
    script=`readlink -f $0`
    rulefile=/lib/udev/rules.d/99-usb-audio-auto-select.rules
    if [ -e $rulefile ]
    then
        echo "udev rule already exists: $rulefile"
    else
        echo "Creating udev rule: $rulefile"
        echo "ACTION==\"add\", SUBSYSTEM==\"usb\", DRIVERS==\"snd-usb-audio\", RUN+=\"$script\"" > $rulefile
        service udev restart
    fi
    rulefile=/usr/lib/pm-utils/sleep.d/99usbaudio    
    if [ -e $rulefile ]
    then
        echo "pm-utils sleep/wake rule already exists: $rulefile"
    else
        echo "Creating pm-utils sleep/wake rule: $rulefile"
        echo -e "#!/bin/sh \n case \"\$1\" in \n 'resume' | 'thaw') \n $script \n ;; \n esac" > $rulefile
        chmod a+x $rulefile
    fi
    exit 0
fi

if [ "$1" = "--sleep" ]
then
    sleep 1
fi

if [ "$UID" == "0" ]
then
    # Check process table for users running PulseAudio
    for user in `ps axc -o user,command | grep pulseaudio | cut -f1 -d' ' | sort | uniq`
    do
        # Fork and relaunch this script as each pulseaudio user
        # tell it to sleep for a second to let pulseaudio install the usb device
        su $user -c "bash $0 --sleep" &
    done
else
    # Use grep to figure out the name of the usb speaker
    speaker=`pacmd list-sinks | grep 'name:' | grep usb | sed 's/.*<//g;s/>.*//g;' | head -n 1`
    # Use grep to figure out the name of the usb microphone
    mic=`pacmd list-sources | grep 'name:' | grep input | grep usb | sed 's/.*<//g;s/>.*//g;' | head -n 1`

    if [ "z$speaker" != "z" ]
    then
        # use this speaker
        pacmd  set-default-sink "$speaker" | grep -vE 'Welcome|>>> $'
        # unmute
        pacmd  set-sink-mute "$speaker" 0 | grep -vE 'Welcome|>>> $'
        # Set the volume.  20000 is 20%
        pacmd  set-sink-volume "$speaker" 20000 | grep -vE 'Welcome|>>> $'
    fi

    if [ "z$mic" != "z" ]
    then
        # use this microphone
        pacmd  set-default-source "$mic" | grep -vE 'Welcome|>>> $'
        # unmute
        pacmd  set-source-mute "$mic" 0 | grep -vE 'Welcome|>>> $'
        # Set the volume.  80000 is 80%
        pacmd  set-source-volume "$mic" 80000 | grep -vE 'Welcome|>>> $'
    fi

    #play a sound to let you know that it was plugged in
    play /usr/share/sounds/speech-dispatcher/test.wav 2> /dev/null
fi

exit 0
