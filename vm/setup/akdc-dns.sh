#!/bin/bash

if [ "$AKDC_SSL" = "" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  skipping dns setup" >> "$HOME/status"
  exit 0
fi

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-dns start" >> "$HOME/status"

set -e

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-dns start" >> "$HOME/status"
echo "$(date +'%Y-%m-%d %H:%M:%S')  creating DNS entry" >> "$HOME/status"

if [ "$AKDC_DO" = "true" ]
then
  # get the public IP
  pip="$(ip -4 a show eth0 | grep inet | sed "s/inet//g" | sed "s/ //g" | cut -d / -f 1 | grep -v '10\.')"
else
  # get the public IP
  pip=$(az network public-ip show -g "$AKDC_RESOURCE_GROUP" -n "${AKDC_CLUSTER}publicip" --query ipAddress -o tsv)
fi

echo "$(date +'%Y-%m-%d %H:%M:%S')  Public IP: $pip" >> "$HOME/status"
echo "Public IP: $pip"

# get the old IP
old_ip=$(az network dns record-set a list \
--query "[?name=='$AKDC_CLUSTER'].{IP:aRecords}" \
--resource-group "$AKDC_DNS_RG" \
--zone-name "$AKDC_ZONE" \
-o json | jq -r '.[].IP[].ipv4Address' | tail -n1)

# delete old DNS entry if exists
if [ "$old_ip" != "" ] && [ "$old_ip" != "$pip" ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S')  deleting old DNS entry old: $old_ip pip: $pip" >> "$HOME/status"

  # delete the old DNS entry
  az network dns record-set a remove-record \
  -g "$AKDC_DNS_RG" \
  -z "$AKDC_ZONE" \
  -n "$AKDC_CLUSTER" \
  -a "$old_ip" -o table
fi

# create DNS record
az network dns record-set a add-record \
-g "$AKDC_DNS_RG" \
-z "$AKDC_ZONE" \
-n "$AKDC_CLUSTER" \
-a "$pip" \
--ttl 10 -o table

echo "$(date +'%Y-%m-%d %H:%M:%S')  akdc-dns complete" >> "$HOME/status"
