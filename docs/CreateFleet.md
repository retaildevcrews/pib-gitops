# Retail Edge Onboarding

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Platform Team Contacts

- anflinch
- bartr
- kevinshah

## Create a Fleet

> If you need more than 3 clusters in your fleet - contact the Platform Team in advance
>
> We have limited Azure quotas

## Create a fleet in the shared subscription

> Request access to this repo from the platform team

- Create a new Codespaces from the main branch

## Login to Azure using the Service Principal

```bash

flt az login

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

## Check Env Vars

- Update as required
  - You can run `code ~/.zshrc` to make the changes permanent
    - You will need to restart your shell

    ```bash

    flt env

    ```

    - Output

    ```text

    AKDC_DNS_RG=tld
    AKDC_GITOPS=true
    AKDC_HUB_NAME=voe-iot-hub
    AKDC_MI=/subscriptions/...
    AKDC_PAT=ghp_...
    AKDC_REPO=retaildevcrews/bartr-fleet
    AKDC_SSL=cseretail.com

    ```

## Check your .ssh directory for secrets

```bash

ll ~/.ssh

```

- Output

  ```text

  -rw------- 1 vscode vscode   41 Jun 28 15:30 akdc.pat
  -rw------- 1 vscode vscode 1.7K Jun 28 15:30 certs.key
  -rw------- 1 vscode vscode 6.2K Jun 28 15:30 certs.pem
  -rw------- 1 vscode vscode 1.7K Jun 28 15:30 id_rsa
  -rw------- 1 vscode vscode  381 Jun 28 15:30 id_rsa.pub

  ```

## Create Your Fleet

- Single Cluster Fleet

  ```bash

  # lower case only
  # choose a different number than "123"
  # region in [ central east west ]
  # format:
  #  region-state-city-storeNumber

  flt create -c central-tx-dfw-123

  ```

## Delete Fleet

- Single Cluster Fleet

  ```bash

  # use the same name as you created
  flt delete central-tx-dfw-123

  ```

## Create a multi-cluster Fleet

  ```bash

  # choose a different number than "123"
  # change "yourAlias"

  flt create \
    -g yourAlias-fleet
    -c central-tx-dfw-123 \
    -c east-ga-atl-123 \
    -c west-wa-sea-123

  ```

- Delete Your Fleet

  ```bash

  # use the same names as you created

  # delete each DNS entry
  flt delete central-tx-dfw-123
  flt delete east-ga-atl-123
  flt delete west-wa-sea-123

  # delete the Azure resource group
  flt delete yourAlias-fleet

  ```

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
