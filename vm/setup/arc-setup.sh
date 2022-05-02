#!/usr/bin/env bash

set -e

echo "$(date +'%Y-%m-%d %H:%M:%S')  arc-setup start" >> "$HOME/status"

if [ "$AKDC_ARC_ENABLED" = "true" ]; then
  # add azure arc dependencies
  echo "$(date +'%Y-%m-%d %H:%M:%S')   install azure arc dependencies" >> "$HOME/status"
  az extension add --name connectedk8s
  az provider register --namespace Microsoft.Kubernetes
  az provider register --namespace Microsoft.KubernetesConfiguration
  az provider register --namespace Microsoft.ExtendedLocation

  # connect k3d to azure arc
  echo "$(date +'%Y-%m-%d %H:%M:%S')   connect k3d cluster to azure via azure arc" >> "$HOME/status"
  az connectedk8s connect --name "$AKDC_CLUSTER" --resource-group "$AKDC_RESOURCE_GROUP"
fi

echo "$(date +'%Y-%m-%d %H:%M:%S')  arc-setup complete" >> "$HOME/status"
