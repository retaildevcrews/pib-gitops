#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

# change these for your repo
export REPO_BASE=$PWD
export AKDC_REPO=$GITHUB_REPOSITORY
export AKDC_GITOPS=true
export AKDC_SSL=cseretail.com
export AKDC_DNS_RG=tld

export PATH="$PATH:$REPO_BASE/bin"
export GOPATH="$HOME/go"

mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/go"
mkdir -p "$HOME/.oh-my-zsh/completions"

{
    echo "defaultIPs: $REPO_BASE/ips"
    echo "reservedClusterPrefixes:"
    echo "  - corp-monitoring"
    echo "  - central-mo-kc"
    echo "  - central-tx-austin"
    echo "  - east-ga-atlanta"
    echo "  - east-nc-raleigh"
    echo "  - west-ca-sd"
    echo "  - west-wa-redmond"
    echo "  - west-wa-seattle"
} > "$HOME/.flt"

{
    # add cli to path
    echo "export PATH=\$PATH:$REPO_BASE/bin"
    echo "export GOPATH=\$HOME/go"

    echo "export REPO_BASE=$REPO_BASE"
    echo "export AKDC_REPO=$AKDC_REPO"
    echo "export AKDC_GITOPS=$AKDC_GITOPS"
    echo "export AKDC_SSL=$AKDC_SSL"
    echo "export AKDC_DNS_RG=$AKDC_DNS_RG"
    echo "export PIB_GHCR=ghcr.io/cse-labs"

    echo ""
    echo "if [ \"\$PAT\" != \"\" ]"
    echo "then"
    echo "    export GITHUB_TOKEN=\$PAT"
    echo "fi"

    echo ""
    echo "export AKDC_PAT=\$GITHUB_TOKEN"

    echo ""
    echo "compinit"

} >> "$HOME/.zshrc"

# echo "generating completions"
flt completion zsh > "$HOME/.oh-my-zsh/completions/_flt"
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"

echo "create local registry"
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

echo "create the cluster"
kic cluster create

echo "pull images"
docker pull mcr.microsoft.com/dotnet/sdk:6.0
docker pull mcr.microsoft.com/dotnet/aspnet:6.0-alpine

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    echo "$(date +'%Y-%m-%d %H:%M:%S')    upgrading" >> "$HOME/status"
    sudo apt-get update
    sudo apt-get upgrade -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
