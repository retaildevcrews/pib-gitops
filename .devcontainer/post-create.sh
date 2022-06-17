#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create start" >> "$HOME/status"

# secrets are not available during on-create

mkdir -p "$HOME/.ssh"

if [ "$PAT" != "" ]
then
    echo "$PAT" > "$HOME/.ssh/akdc.pat"
    chmod 600 "$HOME/.ssh/akdc.pat"
fi

# add shared ssh key
if [ "$ID_RSA" != "" ] && [ "$ID_RSA_PUB" != "" ]
then
    echo "$ID_RSA" | base64 -d > "$HOME/.ssh/id_rsa"
    echo "$ID_RSA_PUB" | base64 -d > "$HOME/.ssh/id_rsa.pub"
    chmod 600 "$HOME"/.ssh/id*
fi

# add shared ssh key
if [ "$CSE_RETAIL_CERT" != "" ] && [ "$CSE_RETAIL_KEY" != "" ]
then
    echo "$CSE_RETAIL_CERT" | base64 -d > "$HOME/.ssh/certs.pem"
    echo "$CSE_RETAIL_KEY" | base64 -d > "$HOME/.ssh/certs.key"
    chmod 600 "$HOME"/.ssh/certs*
fi

# update oh-my-zsh
git -C "$HOME/.oh-my-zsh" pull

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"
