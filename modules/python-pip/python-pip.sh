#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_yaml_array INSTALL '.install[]' "$1"
get_yaml_array REMOVE '.remove[]' "$1"

# The installation is done with some wordsplitting hacks
# because of errors when doing array destructuring at the installation step.
# This is different from other ublue projects and could be investigated further.
INSTALL_STR=$(echo "${INSTALL[*]}" | tr -d '\n')
REMOVE_STR=$(echo "${REMOVE[*]}" | tr -d '\n')

# Install and remove packages
if [[ ${#INSTALL[@]} -gt 0 && ${#REMOVE[@]} -gt 0 ]]; then
    echo "Installing & Removing Python packages"
    echo "Installing: ${INSTALL_STR[*]}"
    echo "Removing: ${REMOVE_STR[*]}"
    # Uninstall packages
    pip uninstall -y $REMOVE_STR
    # Install packages
    pip install $INSTALL_STR
elif [[ ${#INSTALL[@]} -gt 0 ]]; then
    echo "Installing Python packages"
    echo "Installing: ${INSTALL_STR[*]}"
    pip install $INSTALL_STR
elif [[ ${#REMOVE[@]} -gt 0 ]]; then
    echo "Removing Python packages"
    echo "Removing: ${REMOVE_STR[*]}"
    pip uninstall -y $REMOVE_STR
fi
