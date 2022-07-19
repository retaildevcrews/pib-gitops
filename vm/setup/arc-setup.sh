#!/usr/bin/env bash

set -e

echo "$(date +'%Y-%m-%d %H:%M:%S')  arc-setup start" >> "$HOME/status"

if [ "$AKDC_ARC_ENABLED" != "true" ]; then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  arc-setup complete" >> "$HOME/status"
  exit 0
fi

# add azure arc dependencies
echo "$(date +'%Y-%m-%d %H:%M:%S')  install Arc dependencies" >> "$HOME/status"
az extension add --name connectedk8s
az extension add --name k8s-configuration
az extension add --name  k8s-extension
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation

# make sure cluster name is set
if [ -z "$AKDC_CLUSTER" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_CLUSTER not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  arc setup failed" >> "$HOME/status"
  echo "AKDC_CLUSTER not set"
  exit 1
fi

# make sure resource group is set
if [ -z "$AKDC_RESOURCE_GROUP" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_RESOURCE_GROUP not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  arc setup failed" >> "$HOME/status"
  echo "AKDC_CLUSTER not set"
  exit 1
fi

# make sure the branch is set
if [ -z "$AKDC_BRANCH" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_BRANCH not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  arc setup failed" >> "$HOME/status"
  echo "AKDC_BRANCH not set"
  exit 1
fi

# make sure the branch is set
if [ -z "$AKDC_PAT" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_PAT not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  arc setup failed" >> "$HOME/status"
  echo "AKDC_BRANCH not set"
  exit 1
fi

# connect K8s to Arc
echo "$(date +'%Y-%m-%d %H:%M:%S')  Arc enable cluster" >> "$HOME/status"
echo "Arc enable cluster"
az connectedk8s connect --name "$AKDC_CLUSTER" --resource-group "$AKDC_RESOURCE_GROUP"

echo "$(date +'%Y-%m-%d %H:%M:%S')  Arc enable GitOps" >> "$HOME/status"
echo "Arc enable GitOps"

# add flux extension
az k8s-configuration flux create \
  --cluster-type connectedClusters \
  --interval 1m \
  --kind git \
  --name gitops \
  --namespace flux-system \
  --scope cluster \
  --timeout 3m \
  --https-user gitops \
  --cluster-name $AKDC_CLUSTER \
  --resource-group $AKDC_RESOURCE_GROUP \
  --url https://github.com/$AKDC_REPO \
  --branch $AKDC_BRANCH \
  --https-key $AKDC_PAT \
  --kustomization \
      name=flux-system \
      path=./clusters/$AKDC_CLUSTER/flux-system/workspaces \
      timeout=3m \
      sync_interval=1m \
      retry_interval=1m \
      prune=true \
      force=true

# setup Key Vault
if [ "$AKDC_KEY_VAULT" != "" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  Arc enable key vault" >> "$HOME/status"
  # add key vault extension
  az k8s-extension create \
    --cluster-name $AKDC_CLUSTER \
    --resource-group $AKDC_RESOURCE_GROUP \
    --cluster-type connectedClusters \
    --extension-type Microsoft.AzureKeyVaultSecretsProvider \
    --name $AKDC_KEY_VAULT
fi

echo "$(date +'%Y-%m-%d %H:%M:%S')  arc-setup complete" >> "$HOME/status"
