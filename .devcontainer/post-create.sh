#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create start" >> "$HOME/status"

# secrets are not available during on-create

mkdir -p "$HOME/.ssh"

if [ "$GITHUB_TOKEN" != "" ]
then
    echo "$GITHUB_TOKEN" > "$HOME/.ssh/akdc.pat"
    chmod 600 "$HOME/.ssh/akdc.pat"
fi

# override with personal PAT
if [ "$PAT" != "" ]
then
    echo "$PAT" > "$HOME/.ssh/akdc.pat"
    chmod 600 "$HOME/.ssh/akdc.pat"
fi

# override with Codespaces secret
if [ "$AKDC_PAT" != "" ]
then
    echo "$AKDC_PAT" > "$HOME/.ssh/akdc.pat"
    chmod 600 "$HOME/.ssh/akdc.pat"
fi

# add shared ssh key
if [ "$ID_RSA" != "" ] && [ "$ID_RSA_PUB" != "" ]
then
    echo "$ID_RSA" | base64 -d > "$HOME/.ssh/id_rsa"
    echo "$ID_RSA_PUB" | base64 -d > "$HOME/.ssh/id_rsa.pub"
    chmod 600 "$HOME"/.ssh/id*
fi

# update oh-my-zsh
git -C "$HOME/.oh-my-zsh" pull

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"
