#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

echo "$(date +'%Y-%m-%d %H:%M:%S')  k3d-setup start" >> "$HOME/status"

# fail if k3d.yaml isn't present
if [ ! -f ./k3d.yaml ]
then
  echo "failed (k3d.yaml not found)"
  exit 1
fi

# this will fail harmlessly if a cluster doesn't exist
k3d cluster delete

echo "$(date +'%Y-%m-%d %H:%M:%S')  transforming registries.yaml" >>"$HOME/status"
AKDC_PAT=$(cat /home/akdc/.ssh/akdc.pat)
cp ./registries.templ /home/akdc/registries.yaml
sed -i -e "s/{{akdc-pat}}/$AKDC_PAT/g" /home/akdc/registries.yaml

# create the cluster (run as akdc)
k3d cluster create \
  --registry-use k3d-registry.localhost:5500 \
  --registry-config /home/akdc/registries.yaml \
  --config ./k3d.yaml \
  --k3s-server-arg '--no-deploy=traefik'

# sleep to avoid timing issues
sleep 5
kubectl wait node --all  --for condition=ready --timeout 30s
sleep 5
kubectl wait pod -l k8s-app=kube-dns -n kube-system --for condition=ready --timeout 30s

# Install istio resources on cluster
echo "$(date +'%Y-%m-%d %H:%M:%S')  installing istio resources" >> "$HOME/status"
istioctl install --set profile=demo -y

# setup Dapr and Radius
if [ "$AKDC_DAPR" = "true" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  installing dapr" >> "$HOME/status"
  wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | sudo /bin/bash
  sudo dapr init -k --enable-mtls=false --wait
fi

echo "$(date +'%Y-%m-%d %H:%M:%S')  k3d-setup complete" >> "$HOME/status"
