#!/bin/bash

echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap start" >> "$HOME/status"

if [ ! "$(flux --version)" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux not found" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  exit 1
fi

if [ -z "$AKDC_BRANCH" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_BRANCH not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  echo "AKDC_BRANCH not set"
  exit 1
fi

if [ -z "$AKDC_CLUSTER" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  AKDC_CLUSTER not set" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  echo "AKDC_CLUSTER not set"
  exit 1
fi

if [ ! -f /home/akdc/.ssh/akdc.pat ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc.pat not found" >> "$HOME/status"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap failed" >> "$HOME/status"
  echo "akdc.pat not found"
  exit 1
fi

status_code=1
retry_count=0

until [ $status_code == 0 ]; do

  echo "flux retries: $retry_count"
  echo "$(date +'%Y-%m-%d %H:%M:%S')  flux retries: $retry_count" >> "$HOME/status"

  if [ $retry_count -gt 0 ]
  then
    sleep $((RANDOM % 30+15))
  fi

  retry_count=$((retry_count + 1))

  flux bootstrap git \
  --url "https://github.com/$AKDC_REPO" \
  --branch "$AKDC_BRANCH" \
  --password "$(cat /home/akdc/.ssh/akdc.pat)" \
  --token-auth true \
  --path "./deploy/bootstrap/$AKDC_CLUSTER"

  status_code=$?
done

echo "adding flux sources"
echo "$(date +'%Y-%m-%d %H:%M:%S')  adding flux sources" >> "$HOME/status"

flux create secret git gitops \
  --url "https://github.com/$AKDC_REPO" \
  --password "$(cat /home/akdc/.ssh/akdc.pat)" \
  --username gitops

flux create source git gitops \
--url "https://github.com/$AKDC_REPO" \
--branch "$AKDC_BRANCH" \
--secret-ref gitops

flux create kustomization bootstrap \
--source GitRepository/gitops \
--path "./deploy/bootstrap/$AKDC_CLUSTER" \
--prune true \
--interval 1m

flux create kustomization apps \
--source GitRepository/gitops \
--path "./deploy/apps/$AKDC_CLUSTER" \
--prune true \
--interval 1m

flux reconcile source git gitops

kubectl get pods -A

flux get kustomizations

echo "$(date +'%Y-%m-%d %H:%M:%S')  flux bootstrap complete" >> "$HOME/status"
