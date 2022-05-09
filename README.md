# Retail Edge Onboarding

![License](https://img.shields.io/badge/license-MIT-green.svg)

- `Retail Edge` allows you to quickly create Kubernetes clusters running `k3d` in `Azure VMs`
- These cluster are intended for learning, dev and test
- For secure or production clusters, we recommend [AKS Secure Baseline](https://github.com/mspnp/aks-baseline)

## Platform Team Contacts

- anflinch
- bartr
- devwag
- kevinshah

## Prerequisites

> Recommended learning

- Go through the Kubernetes in Codespaces inner-loop hands-on lab [here](https://github.com/cse-labs/kubernetes-in-codespaces)
  - Repeat until you are comfortable with Codespaces, Kubernetes, Prometheus, Fluent Bit, Grafana, K9s, and our inner-loop process (everything builds on this)
- Go through the GitOps Automation [Quick Start](https://github.com/bartr/autogitops)
  - Repeat until you are comfortable (GitOps builds on this)

## Click on `Use this template` and create your GitOps repo

- Only clone the main branch
- Additional instructions reference your new GitHub repo, not this repo

## Verify ci-cd

- Open the `Actions` tab in your repo at GitHub.com
  - The action needs read / write permission
  - You may have to change your default permission
    - Settings
      - Actions
        - General

## Create a Codespace

- Create your Codespace from your new repo
  - Click on `Code` then click `New Codespace`

Once Codespaces is running:

> Make sure your terminal is running zsh - bash is not supported and will not work
>
> If it's running bash, exit and create a new terminal (this is a random bug in Codespaces)

## Validate your setup

> It is a best practice to close the first shell and start a new one - sometimes the shell starts before setup is complete and isn't fully configured

```bash

# check your PAT - the two values should be the same
echo $AKDC_PAT
echo $GITHUB_TOKEN

# check your env vars
flt env

# output
# AKDC_GITOPS=true
# AKDC_PAT=yourPAT
# AKDC_REPO=yourRepoTenant/yourRepoName

```

## Set Flux repo and branch

- Edit `apps/flux-system/autogitops/config.json`
  - Set `fluxRepo` and `fluxBranch`
  - Git commit and push

## Login to Azure

- Run `az login`
  - Select your subscription if required

## Check availability of VM SKU in Azure region

```bash

# default azure region is centralus
az vm list-sizes -l yourLocation -o table | grep -e Standard_D4as_v5 -e Standard_D4s_v5

```

## Create a single cluster fleet

- ` flt create -c your-cluster-name --verbose`
  - do not specify `--arc` if you are using a normal AIRS subscription
  - do not specify `--ssl` unless you have domain, DNS, and wildcard cert setup
  - specify `--verbose` to see verbose output
  - if VM SKU is not available in default region (centralus), specify `-l yourLocation` to create cluster in different region

## Update your GitOps repo

```bash

# you should see new files from ci-cd
# if you don't, check the Actions tab
git pull

# add and commit the ips file
git add .
git commit -am "added ips file"
git push

```

## Check setup status

> flt is the fleet CLI provided by Retail Edge / Pilot-in-a-Box
>
> The `flt check` commands will fail until SSHD is running, so you may get errors for 30 seconds or so

- Run until you get a status of "complete"
  - Usually 4-5 min

```bash

# check setup status
flt check setup

```

## Check your Fleet

```bash

# list clusters in the fleet
flt list

# check heartbeat on the fleet
# you should get 17 bytes from each cluster
# if not, please reach out to the Platform Team for support
flt check heartbeat

# update the fleet
# (run twice if there are updates so you can see it's clean)
flt pull

```

## Deploy the Reference App

- IMDb is the reference app
- Normally, the apps would be in separate repos
  - We include the reference app in this repo for convenience
  - Heartbeat and Istio are `bootstrap services` and should be in this repo

```bash

cd apps/imdb

# check deploy targets (should be [])
flt targets list

# clear the targets if not []
flt targets clear

# add your cluster as a target
flt targets add yourClusterName

# deploy the changes
flt targets deploy

```

## Check that your GitHub Action is running

- <https://github.com/retaildevcrews/edge-gitops/actions>
  - your action should be queued or in-progress

## Check deployment

- Once the action completes successfully

```bash

# you should see imdb added to your cluster
git pull

# force flux to sync
# flux will sync on a schedule - this command forces it to sync now for debugging
flt sync

# check that imdb is deployed to your cluster
flt check app imdb

# curl the IMDb endpoints
flt curl /version
flt curl /healthz
flt curl /readyz

```

## Delete your test cluster

```bash

git pull

flt delete yourCluster

## you can skip these steps if you're deleting the repo

# delete your cluster config & deployments
rm ips
rm -rf config/yourClusterName
rm -rf deploy/apps/yourClusterName
rm -rf deploy/bootstrap/yourClusterName
rm -rf deploy/flux/yourClusterName

# commit and push to GitHub
git add .
git commit -am "delete cluster config & deployments"
git push

```

## Create a Fleet

- We generally group our fleets together in one resource group
- An example of creating a 3 cluster fleet
  - this will create the following meta data which can be used as targets
    - region:central
    - zone:central-tx
    - district:central-tx-atx
    - store:central-tx-atx-801

  ```bash

  flt create -g my-fleet \
    -c central-tx-atx-801 \
    -c east-ga-atl-801 \
    -c west-wa-sea-801

  ```

## Setup your GitHub PAT

> GitOps needs a PAT that can push to this repo
>
> You can use your Codespaces token but it will be deleted when your Codespace is deleted and GitOps will quit working

### For production, you want to use a service account instead of your individual account

- Create a Personal Access Token (PAT) in your GitHub account
  - Grant repo and package access
  - You can use an existing PAT as long as it has permissions
  - <https://github.com/settings/tokens>

- Create a personal Codespace secret
  - <https://github.com/settings/codespaces>
  - Name: PAT
  - Value: your PAT
  - Grant access to this repo and any other repos you want

## Setup your Azure Subscription

- If you plan to use Azure Arc
  - Request a `sponsored subscription` from AIRS
- Additional setup is required
  - Contact the Platform Team for more details
    - domain name
    - DNS
    - SSL wildcard cert
    - Managed Identity
    - Key Vault
    - Service Principal

## How to file issues and get help

This project uses GitHub Issues to track bugs and feature requests. Please search the existing issues before filing new issues to avoid duplicates. For new issues, file your bug or feature request as a new issue.

For help and questions about using this project, please open a GitHub issue.

### Engineering Docs

- Team Working [Agreement](.github/WorkingAgreement.md)
- Team [Engineering Practices](.github/EngineeringPractices.md)
- CSE Engineering Fundamentals [Playbook](https://github.com/Microsoft/code-with-engineering-playbook)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services.

Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).

Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.

Any use of third-party trademarks or logos are subject to those third-party's policies.
