#!/bin/bash

echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap start" >> "$HOME/status"

# make sure flux is installed
if [ ! "$(flux --version)" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux not found" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  exit 1
fi

# make sure the branch is set
if [ -z "$AKDC_BRANCH" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_BRANCH not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  echo "AKDC_BRANCH not set"
  exit 1
fi

# make sure cluster name is set
if [ -z "$AKDC_CLUSTER" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_CLUSTER not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  echo "AKDC_CLUSTER not set"
  exit 1
fi

# make sure PAT is set
if [ ! -f /home/akdc/.ssh/akdc.pat ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc.pat not found" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  echo "akdc.pat not found"
  exit 1
fi

git pull

kubectl apply -f "$HOME/gitops/clusters/$AKDC_CLUSTER/flux-system/flux-system/namespace.yaml"
flux create secret git flux-system -n flux-system --url "https://github.com/$AKDC_REPO" -u gitops -p "$AKDC_PAT"
flux create secret git gitops -n flux-system --url "https://github.com/$AKDC_REPO" -u gitops -p "$AKDC_PAT"

kubectl apply -f "$HOME/gitops/clusters/$AKDC_CLUSTER/flux-system/flux-system/controllers.yaml"
sleep 3
kubectl apply -f "$HOME/gitops/clusters/$AKDC_CLUSTER/flux-system/flux-system/source.yaml"
sleep 2
kubectl apply -R -f "$HOME/gitops/clusters/$AKDC_CLUSTER/flux-system/flux-system"
sleep 5

# force flux to sync
flux reconcile source git gitops

# display results
kubectl get pods -A
flux get kustomizations

echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap complete" >> "$HOME/status"
