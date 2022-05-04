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
if [ "$AKDC_ID_RSA" != "" ] && [ "$AKDC_ID_RSA_PUB" != "" ]
then
    echo "$AKDC_ID_RSA" | base64 -d > "$HOME/.ssh/id_rsa"
    echo "$AKDC_ID_RSA_PUB" | base64 -d > "$HOME/.ssh/id_rsa.pub"
    chmod 600 "$HOME"/.ssh/id*
fi

# update oh-my-zsh
git -C "$HOME/.oh-my-zsh" pull

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"
