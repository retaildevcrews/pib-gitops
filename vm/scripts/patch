#!/bin/bash
echo "$(date +'%Y-%m-%d %H:%M:%S')  patched" >> /home/akdc/status

# pull the latest docker images
docker pull ghcr.io/cse-labs/webv-red:latest
docker pull ghcr.io/cse-labs/webv-red:beta

echo "$(hostname) patched"
