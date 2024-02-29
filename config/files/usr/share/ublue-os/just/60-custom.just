# most of this is from bazzite

# # Update system, flatpaks, and containers all at once
# update:
#     #!/usr/bin/bash
#     /usr/bin/topgrade --config /usr/share/ublue-os/topgrade.toml --keep

# Apply the silverblue usergroup workaround to fix my user groups
fix-user-groups:
    #!/usr/bin/bash
    groups=("libvirt" "kvm" "qemu" "docker") && \
    sudo bash -c 'for group in "${groups[@]}"; do usermod -a -G "$group" && grep -E "^$group:" /usr/lib/group >> /etc/group; done'

# # Fix the default Steam config to improve download speeds
# fix-steam-download-speed:
#     mkdir -p $HOME/.local/share/Steam
#     rm -f $HOME/.local/share/Steam/steam_dev.cfg
#     bash -c 'printf "@nClientDownloadEnableHTTP2PlatformLinux 0\n@fDownloadRateImprovementToAddAnotherConnection 1.0\n" > $HOME/.local/share/Steam/steam_dev.cfg'

# # Remove all waydroid-related files in your user folders
# reset-waydroid:
#     bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'

# # Quickly initialize a waydroid image
# init-waydroid:
#     #!/usr/bin/bash
#     sudo waydroid init -c 'https://ota.waydro.id/system' -v 'https://ota.waydro.id/vendor'

# # Launch Waydroid configuration helper
# configure-waydroid:
#     #!/usr/bin/bash
#     git clone https://github.com/ublue-os/waydroid_script.git --depth 1 /tmp/waydroid_script
#     python -m venv /tmp/waydroid_script/venv
#     source /tmp/waydroid_script/venv/bin/activate
#     sudo pip install -r /tmp/waydroid_script/requirements.txt
#     sudo /tmp/waydroid_script/main.py
#     deactivate
#     sudo rm -rf /tmp/waydroid_script

# # Enable Virtualization and add workaround for a specific windows VM crash
# enable-virtualization:
#     #!/usr/bin/bash
#     virt_test=$(rpm-ostree status | grep -A 4 "●" | grep "virt-manager")
#     if [[ -z ${virt_test} ]]; then
#       echo "Installing QEMU and virt-manager..."
#       rpm-ostree install -y virt-manager edk2-ovmf qemu
#       rpm-ostree kargs \
#       --append-if-missing="kvm.ignore_msrs=1" \
#       --append-if-missing="kvm.report_ignored_msrs=0"
#       echo 'Please re-run "ujust enable-virtualization" after the reboot to finish setup'
#     else
#       echo "Enabling libvirtd service"
#       sudo systemctl enable --now libvirtd
#       echo "libvirtd enabled! If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
#     fi

# # Enable VFIO on the system if virtualization is enabled
# enable-vfio:
#     #!/usr/bin/bash
#     echo "Enabling VFIO..."
#     VIRT_TEST=$(rpm-ostree kargs)
#     CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
#     VENDOR_KARG="unset"
#     if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
#       echo 'add_drivers+=" vfio vfio_iommu_type1 vfio-pci "' | sudo tee /etc/dracut.conf.d/vfio.conf
#       sudo touch /etc/bazzite/initramfs/rebuild
#       if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
#         VENDOR_KARG="amd_iommu=on"
#       elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
#         VENDOR_KARG="intel_iommu=on"
#       fi
#       if [[ ${VENDOR_KARG} == "unset" ]]; then
#         echo "Failed to get CPU vendor, exiting..."
#         exit 1
#       else
#         rpm-ostree kargs \
#           --append-if-missing="${VENDOR_KARG}" \
#           --append-if-missing="iommu=pt" \
#           --append-if-missing="rd.driver.pre=vfio_pci" \
#           --append-if-missing="vfio_pci.disable_vga=1"
#         echo "lspci -nn | grep 'GPU_VENDOR'"
#         echo 'rpm-ostree kargs --append-if-missing="vfio-pci.ids=xxxx:yyyy,xxxx:yyzz"'
#         echo "NOTE: Your second GPU will not be usable by the host after you do this!"
#       fi
#     else
#       echo "Enable virtualization with ujust enable-virtualization before running ujust enable-vfio."
#     fi

# Add SELinux file context for default looking-glass shm file so that libvirt can create it when needed
selinux-looking-glass:
    sudo tee /etc/tmpfiles.d/10-looking-glass.conf > /dev/null << 'LOOKING_GLASS_TMP'
# Type Path               Mode UID GID Age Argument
f /dev/shm/looking-glass 0660 1000 qemu -
LOOKING_GLASS_TMP
    sudo semanage fcontext -a -t svirt_tmpfs_t "/dev/shm/looking-glass"

# # Install Solaar for Logitech Mice, Keyboards, and Trackpads
# install-solaar: distrobox-check-fedora
#     distrobox-enter -n fedora -- bash -c 'sudo dnf install -y \
#       solaar && \
#       distrobox-export --app solaar' && \
#     mkdir -p ~/.config/autostart && \
#     rm -f ~/.config/autostart/fedora-solaar.desktop && \
#     cp ~/.local/share/applications/fedora-solaar.desktop ~/.config/autostart/fedora-solaar.desktop

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

# # Install Steam, Lutris and all the gaming related apps
# install-gx: distrobox-check-bazzite
#     distrobox-enter -n bazzite-arch --  bash -c 'distrobox-export --app steam && \
#       distrobox-export --app lutris && \
#       distrobox-export --app protontricks && \
#       mkdir -p ~/.steam && \
#       distrobox-export --bin /usr/bin/steamcmd --export-path ~/.steam && \
#       mv ~/.steam/steamcmd ~/.steam/steamcmd.sh'

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      Assemble noconfirmcreate "" "fedora"
    fi

# # Create bazzite-arch distrobox if it doesn't exist
# [private]
# distrobox-check-bazzite:
#     #!/bin/env bash
#     source /usr/lib/ujust/ujust.sh
#     if grep -qvz "bazzite-arch" <<< $(distrobox list); then
#       echo "Setting up Bazzite-Arch distrobox"
#       distrobox-create --image ghcr.io/ublue-os/bazzite-arch \
#         --unshare-netns -Y \
#         --additional-flags "--ulimit nofile=262144:262144"
#     fi
