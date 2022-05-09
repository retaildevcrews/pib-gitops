#!/bin/bash

### to run manually
# cd /home/akdc
# cli/vm/setup/akdc-setup.sh

# this is the main VM setup script

# env variables defined in /etc/bash.bashrc
    # AKDC_ARC_ENABLED
    # AKDC_BRANCH
    # AKDC_CLUSTER
    # AKDC_DEBUG
    # AKDC_DNS_RG
    # AKDC_FQDN
    # AKDC_ME
    # AKDC_REPO
    # AKDC_RESOURCE_GROUP
    # AKDC_ZONE

# change to this directory
# cd "$(dirname "${BASH_SOURCE[0]}")" || exit

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-setup start" >> "$HOME/status"

# can't continue without akdc-install.sh
if [ ! -f "$HOME"/gitops/vm/setup/akdc-install.sh ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-install.sh not found" >> "$HOME/status"
  echo "akdc-install.sh not found"
  exit 1
fi

# can't continue without akdc-dns.sh
if [ ! -f "$HOME"/gitops/vm/setup/akdc-dns.sh ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-dns.sh not found" >> "$HOME/status"
  echo "akdc-dns.sh not found"
  exit 1
fi

# can't continue without k8s-setup.sh
if [ ! -f "$HOME"/gitops/vm/setup/k8s-setup.sh ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  k8s-setup.sh not found" >> "$HOME/status"
  echo "k8s-setup.sh not found"
  exit 1
fi

# can't continue without flux-setup.sh
if [ ! -f "$HOME"/gitops/vm/setup/flux-setup.sh ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux-setup.sh not found" >> "$HOME/status"
  echo "flux-setup.sh not found"
  exit 1
fi

set -e

# run setup scripts
"$HOME"/gitops/vm/setup/akdc-install.sh
"$HOME"/gitops/vm/setup/akdc-dns.sh

# don't run setup in debug mode
if [ "$AKDC_DEBUG" = "true" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  debug mode" >> "$HOME/status"
  echo "debug mode"
  exit 0
fi

# run akdc-pre-k8s.sh
if [ -f "$HOME"/gitops/vm/setup/akdc-pre-k8s.sh ]
then
  # run as AKDC_ME
  "$HOME"/gitops/vm/setup/akdc-pre-k8s.sh
else
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-k8s.sh not found" >> "$HOME/status"
fi

# run k8s-setup
"$HOME"/gitops/vm/setup/k8s-setup.sh

# run akdc-pre-flux.sh
if [ -f "$HOME"/gitops/vm/setup/akdc-pre-flux.sh ]
then
  "$HOME"/gitops/vm/setup/akdc-pre-flux.sh
else
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-flux.sh not found" >> "$HOME/status"
fi

# setup flux
"$HOME"/gitops/vm/setup/flux-setup.sh

# run akdc-pre-arc.sh
if [ -f "$HOME"/gitops/vm/setup/akdc-pre-arc.sh ]
then
  "$HOME"/gitops/vm/setup/akdc-pre-arc.sh
else
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-pre-arc.sh not found" >> "$HOME/status"
fi

# setup azure arc
if [ -f "$HOME"/gitops/vm/setup/arc-setup.sh ]
then
  "$HOME"/gitops/vm/setup/arc-setup.sh
else
  echo "$(date +'%Y-%m-%d %H:%M:%S')  arc-setup.sh not found" >> "$HOME/status"
fi

# run akdc-private-repos.sh
if [ -f "$HOME"/gitops/vm/setup/akdc-private-repos.sh ]
then
  "$HOME"/gitops/vm/setup/akdc-private-repos.sh
else
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-private-repos.sh not found" >> "$HOME/status"
fi

# run akdc-post.sh
if [ -f "$HOME"/gitops/vm/setup/akdc-post.sh ]
then
  "$HOME"/gitops/vm/setup/akdc-post.sh
else
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-post.sh not found" >> "$HOME/status"
fi

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-setup complete" >> "$HOME/status"
echo "complete" >> "$HOME/status"
