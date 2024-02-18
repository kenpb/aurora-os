#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Currently sddm themes usually display the login form in every screen in multi-monitor setups, since this
# behavior is controlled by the theme this scripts makes some changes for a sort of workaround.

qml_file="/usr/share/sddm/themes/01-breeze-fedora/Main.qml"
clock_file="/usr/share/sddm/themes/01-breeze-fedora/components/Clock.qml"
user_file="/usr/share/sddm/themes/01-breeze-fedora/theme.conf.user"

# Here with the breeze theme, we can leverage the timer that makes the UI "fade" after X time of inactiviy,
# we start all the UIs "faded".
sed -i 's/property bool uiVisible: true/property bool uiVisible: false/g' "$qml_file"

# When we start typing it "wakes up" the focused screen UI and makes it visible again,
# leaving the others screens faded, notice that if we move the mouse it will wake up the UI in which the mouse is residing,
# not necessarily the focused one.

# I also switch the wallpaper, this is "scorched earth" I haven't found it's author, let me know if you know him.
sed -i 's|background=/usr/share/backgrounds/default.png|background=/usr/share/backgrounds/aurora-os/background.jpg|' "$user_file"

# Let's hardcode the format of the time to 24h
sed -i 's/text: Qt.formatTime(timeSource.data["Local"]["DateTime"])/text: Qt.formatTime(timeSource.data["Local"]["DateTime"], "H:mm")/g' "$clock_file"
