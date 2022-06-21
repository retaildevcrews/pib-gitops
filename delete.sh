#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

flt delete central-tx-hou-100-fleet2
flt delete kshah-fleet2 &

git pull
git restore -s origin/main config deploy
rm -f ips
rm -f failed.log
git commit -am "reset deploy"
git push
