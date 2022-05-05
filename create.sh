#!/bin/bash

######################################
### Do not run this script in main ###
######################################

# from main branch
git checkout -b kshah3-fleet
git push -u origin kshah3-fleet
# update and run this script
# make sure to check in the ips file generated

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# duplicate this line for each cluster
# change yourClusterName on each line
# do not change your-fleet on each line
flt create --gitops --ssl cseretail.com -g kshah3-fleet -c kshah3-central
