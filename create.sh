#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

export AKDC_GITOPS=true
export AKDC_SSL=cseretail.com
export AKDC_BRANCH=$(git branch --show-current)
export AKDC_REPO=retaildevcrews/gitops-template
export AKDC_DNS_RG=tld

export start="$(date)"
echo "start: $start"
echo "start: $start" > statuss

flt create -g kshah-fleet2 \
    -c central-tx-hou-100-fleet2

echo "start: $start"
echo "end:   $(date)"
echo "end:   $(date)" >> status
