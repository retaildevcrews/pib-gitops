#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

export AKDC_SSL=cseretail.com
export AKDC_GITOPS=true

export REPO_BASE=$PWD
export AKDC_REPO=$GITHUB_REPOSITORY
export AKDC_VM_REPO=gitops

export PATH="$PATH:$REPO_BASE/bin"
export GOPATH="$HOME/go"

mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.oh-my-zsh/completions"

{
    echo "defaultIPs: $PWD/ips"
    echo "reservedClusterPrefixes: corp-monitoring central-mo-kc central-tx-austin east-ga-atlanta east-nc-raleigh west-ca-sd west-wa-redmond west-wa-seattle"
} > "$HOME/.kic"

{
    #shellcheck disable=2016,2028
    echo 'hsort() { read -r; printf "%s\\n" "$REPLY"; sort }'

    # add cli to path
    echo "export PATH=\$PATH:$REPO_BASE/bin"
    echo "export GOPATH=\$HOME/go"

    echo "export REPO_BASE=$REPO_BASE"
    echo "export AKDC_REPO=$AKDC_REPO"
    echo "export AKDC_SSL=$AKDC_SSL"
    echo "export AKDC_GITOPS=$AKDC_GITOPS"
    echo "export AKDC_VM_REPO=$AKDC_VM_REPO"

    echo ""
    echo "if [ \"\$PAT\" != \"\" ]"
    echo "then"
    echo "    export GITHUB_TOKEN=\$PAT"
    echo "fi"

    echo ""
    echo "compinit"

} >> "$HOME/.zshrc"

# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

# pull the base docker images
docker pull mcr.microsoft.com/dotnet/aspnet:6.0-alpine
docker pull mcr.microsoft.com/dotnet/sdk:6.0
docker pull ghcr.io/cse-labs/webv-red:latest
docker pull ghcr.io/cse-labs/webv-red:beta
docker pull ghcr.io/retaildevcrews/autogitops:beta

# install go modules
go install -v github.com/spf13/cobra/cobra@latest
go install -v golang.org/x/lint/golint@latest
go install -v github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
go install -v github.com/ramya-rao-a/go-outline@latest
go install -v github.com/cweill/gotests/gotests@latest
go install -v github.com/fatih/gomodifytags@latest
go install -v github.com/josharian/impl@latest
go install -v github.com/haya14busa/goplay/cmd/goplay@latest
go install -v github.com/go-delve/delve/cmd/dlv@latest
go install -v honnef.co/go/tools/cmd/staticcheck@latest
go install -v golang.org/x/tools/gopls@latest

# clone repos
cd ..
git clone https://github.com/microsoft/webvalidate
git clone https://github.com/cse-labs/imdb-app
git clone https://github.com/cse-labs/kubernetes-in-codespaces inner-loop
cd "$REPO_BASE" || exit

# echo "generating kic completion"
flt completion zsh > "$HOME/.oh-my-zsh/completions/_flt"
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
flux completion zsh > "$HOME/.oh-my-zsh/completions/_flux"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    echo "$(date +'%Y-%m-%d %H:%M:%S')    upgrading" >> "$HOME/status"
    sudo apt-get update
    sudo apt-get upgrade -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
