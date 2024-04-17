# most of this is from bazzite

# Apply the silverblue usergroup workaround to fix my user groups
fix-user-groups:
    #!/usr/bin/bash
    groups=("libvirt" "kvm" "qemu" "docker") && \
    sudo bash -c 'for group in "${groups[@]}"; do usermod -a -G "$group" && grep -E "^$group:" /usr/lib/group >> /etc/group; done'

# Install the looking-glass client binary
install-looking-glass: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c "sudo dnf copr enable pgaskin/looking-glass-client -y && \
      sudo dnf update -y && \
      sudo dnf install looking-glass-client -y && \
      distrobox-export --bin /usr/bin/looking-glass-client"
    echo "Run looking-glass-client in a terminal to run the client"

# Install dive for docker images exploration
install-dive: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c 'DIVE_VERSION=$(curl -sL \
        "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep "\"tag_name\":" | sed -E "s/.*\"v([^\"]+)\".*/\\1/") && \
      sudo dnf install -y \
        "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm" && \
      distrobox-export --bin /usr/bin/dive'

install-windows-fonts: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c 'sudo dnf install -y \
        https://www.cabextract.org.uk/cabextract-1.11-1.x86_64.rpm && \
    _sfurl="http://downloads.sourceforge.net/corefonts" && \
    fonts=($_sfurl/andale32.exe $_sfurl/arial32.exe $_sfurl/arialb32.exe $_sfurl/comic32.exe $_sfurl/courie32.exe $_sfurl/georgi32.exe \
    $_sfurl/impact32.exe $_sfurl/times32.exe $_sfurl/trebuc32.exe $_sfurl/verdan32.exe $_sfurl/webdin32.exe) && \
    for i in "${fonts[@]}"; do wget $$i && cabextract $$(basename $$i) -d fonts; done && \
    mkdir ~/.local/share/fonts && \
    mkdir ~/.local/share/fonts/mscorefonts && \
    cp -v fonts/*.ttf fonts/*.TTF ~/.local/share/fonts/mscorefonts/'

# Install Insync for file synchronization with cloud services
install-insync: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c "releasever=$(rpm -q --qf \"%{version}\" -f /etc/fedora-release) && \
      sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key && \
      sudo sh -c \"printf '[insync]\nname=insync repo\nbaseurl=http://yum.insync.io/fedora/\$releasever/\ngpgcheck=1\ngpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key\nenabled=1\nmetadata_expire=120m' > /etc/yum.repos.d/insync.repo\" && \
      sudo dnf update -y && \
      sudo dnf install chromium insync -y && \
      distrobox-export --app insync  --extra-flags \"start\"" && \
    mkdir -p ~/.config/autostart && \
    rm -f ~/.config/autostart/insync.desktop && \
    cp ~/.local/share/applications/fedora-insync.desktop ~/.config/autostart/fedora-insync.desktop && \
    distrobox enter -n fedora -- insync start && \
    echo "The script does not properly insert quotations in the autostart entry." && \
    echo "Add quotes to the command in $HOME/.config/autostart/fedora-insync.desktop like this: \"insync start\""

# Install Rambox for chat and productivity tools management
install-rambox: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c 'version=$(curl --silent \
        "https://api.github.com/repos/ramboxapp/download/releases/latest" | grep -Po "(?<=\"tag_name\": \").*(?=\")") && \
      sudo dnf install -y \
        "https://github.com/ramboxapp/download/releases/download/${version}/Rambox-${version:1}-linux-x64.rpm" && \
      distrobox-export --app rambox' && \
    mkdir -p ~/.config/autostart && \
    rm -f ~/.config/autostart/fedora-rambox.desktop && \
    cp ~/.local/share/applications/fedora-rambox.desktop ~/.config/autostart/fedora-rambox.desktop

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      Assemble noconfirmcreate "" "fedora"
    fi
