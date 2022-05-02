# Retail Edge Onboarding

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Platform Team Contacts

- anflinch
- bartr
- devwag
- kevinshah
- wabrez

## Create a Fleet

> If you need more than 3 clusters in your fleet - contact the Platform Team in advance
>
> We have limited Azure quotas

## Create a fleet in the shared subscription

> Request the Azure Service Principal credentials from the Platform Team

- Create 3 personal Codespace secrets
  - <https://github.com/settings/codespaces>
  - AKDC_SP_ID
  - AKDC_TENANT
  - AKDC_SP_KEY
  - Grant access to this repo and any other repos you want

- Create a new Codespaces from the main branch
- You may be able to restart your exising Codespace

## Validate your Secrets

```bash

# From your Codespaces terminal
# verify that your secrets are set
env | grep AKDC_

```

## Login to Azure using the Service Principal

```bash

flt az-login

```

## Create a new branch

> Make sure you're in the main branch

```bash

# start in main branch
git checkout main
git pull

# create the branch
# make sure the branch ends in -fleet
# use your branch name later as the Azure resource group
git checkout -b your-fleet

# set the upstream
git push -u origin your-fleet


```

- Follow the instructions in create.sh
  - replace 'your-fleet'
  - replace `your-cluster`
  - uncomment `flt create ...` line
- Run `./create.sh`
- If everything works
  - duplicate the `flt create ...` line for each cluster
  - change `yourClusterName`
    - do not change your fleet name
  - Comment the first `flt create ...` line
  - Run `./create.sh` again

- Update delete.sh
  - delete each cluster you created
  - delete your resource group

## Delete Fleet

- Once you're done with your fleet, please delete to free up quota
- Run `/.delete.sh`
- Delete your branch if no longer needed

## Create a fleet in your Azure subscription

> In order to use Arc and HCI, your Azure subscription must have a unique AAD and cannot be in the Microsoft tenant

- Request a `sponsored subscription` via [airs](https://aka.ms/airs)
- Login to your Azure subscription
- From the Azure Portal
  - Purchase a domain name
  - Purchase a wildard SSL certificate

> Work in progress

- Setup DNS
- Create a Key Vault
- Create a Managed Identity
- Grant the MI access to the KV
- Add your certs to Key Vault
  - Detailed instructions are [here](Certificates.md)
- Create a new GitOps repo
- Set your Codespaces secrets on the repo
