#!/usr/bin/bash

set -oue pipefail

systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable bluefin-dx-groups.service
systemctl enable --global bluefin-dx-user-vscode.service
systemctl enable --global swtpm-workaround.service
