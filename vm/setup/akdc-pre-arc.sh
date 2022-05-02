#!/bin/bash

# this runs before arc-setup.sh

# change to this directory
# cd "$(dirname "${BASH_SOURCE[0]}")" || exit

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-arc start" >> "$HOME/status"

# add commands here

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-arc complete" >> "$HOME/status"
