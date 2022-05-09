#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

export REPO_BASE=$PWD
export AKDC_REPO=$GITHUB_REPOSITORY
export AKDC_GITOPS=true
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

    # add path alias
    echo "alias path='echo \$PATH | sed \"s/:/\\\n/g\" | sort'"

    echo "export REPO_BASE=$REPO_BASE"
    echo "export AKDC_REPO=$AKDC_REPO"
    echo "export AKDC_GITOPS=$AKDC_GITOPS"

    # add cli to path
    echo "export PATH=\$PATH:$REPO_BASE/bin"
    echo "export GOPATH=\$HOME/go"

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
