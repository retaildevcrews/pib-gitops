#!/bin/bash

# this script installs most of the components

set -e

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-install start" >> "$HOME/status"

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing libs" >> "$HOME/status"
sudo apt-get install -y net-tools software-properties-common libssl-dev libffi-dev python-dev build-essential lsb-release gnupg-agent

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing utils" >> "$HOME/status"
sudo apt-get install -y curl git wget nano jq zip unzip httpie
sudo apt-get install -y dnsutils coreutils gnupg2 make bash-completion gettext iputils-ping

# add Docker source
echo "$(date +'%Y-%m-%d %H:%M:%S')  adding docker source" >> "$HOME/status"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# add kubenetes source
echo "$(date +'%Y-%m-%d %H:%M:%S')  adding kubernetes source" >> "$HOME/status"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "$(date +'%Y-%m-%d %H:%M:%S')  updating sources" >> "$HOME/status"

# this is failing on large fleets - add one retry

set +e

if ! sudo apt-get update
then
    echo "$(date +'%Y-%m-%d %H:%M:%S')  updating sources (retry)" >> "$HOME/status"
    sleep 30
    set -e
    sudo apt-get update
fi

set -e

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing docker" >> "$HOME/status"
sudo apt-get install -y docker-ce docker-ce-cli

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing kubectl" >> "$HOME/status"
sudo apt-get install -y kubectl

# Install istio CLI
echo "$(date +'%Y-%m-%d %H:%M:%S')  installing istioctl" >> "$HOME/status"
echo "Installing istioctl"
curl -sL https://istio.io/downloadIstioctl | bash -
sudo mv "$HOME/.istioctl/bin/istioctl" /usr/local/bin

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing k3d" >> "$HOME/status"
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | sudo TAG=v4.4.8 bash

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing flux" >> "$HOME/status"
curl -s https://fluxcd.io/install.sh | sudo bash

echo "$(date +'%Y-%m-%d %H:%M:%S')  installing k9s" >> "$HOME/status"
VERSION=$(curl -i https://github.com/derailed/k9s/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
wget "https://github.com/derailed/k9s/releases/download/${VERSION}/k9s_Linux_x86_64.tar.gz"
sudo tar -zxvf k9s_Linux_x86_64.tar.gz -C /usr/local/bin
rm -f k9s_Linux_x86_64.tar.gz

# upgrade Ubuntu
echo "$(date +'%Y-%m-%d %H:%M:%S')  upgrading" >> "$HOME/status"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

sudo chown -R "${AKDC_ME}:${AKDC_ME}" "$HOME"
{
  echo ""
  echo "source <(flux completion bash)"
  echo "source <(k3d completion bash)"
  echo "source <(kivm completion bash)"
  echo "source <(kubectl completion bash)"

  echo ""
  echo 'complete -F __start_kubectl k'
} >> "$HOME/akdc.bashrc"

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-install complete" >> "$HOME/status"
