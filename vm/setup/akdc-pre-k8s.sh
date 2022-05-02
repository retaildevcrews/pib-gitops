#!/bin/bash

# this runs before k8s-setup.sh

# change to this directory
#cd "$(dirname "${BASH_SOURCE[0]}")" || exit

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-k3d start" >> "$HOME/status"

echo "$(date +'%Y-%m-%d %H:%M:%S')  creating registry" >> "$HOME/status"
# create local registry
docker network create k3d

# create container registry
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost


echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-k3d complete" >> "$HOME/status"
