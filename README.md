# Retail Edge Onboarding

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Platform Team Contacts

- anflinch
- bartr
- devwag
- kevinshah
- wabrez

## Prerequisites

> Recommended but not required

- Go through the Kubernetes in Codespaces inner-loop hands-on lab [here](https://github.com/cse-labs/kubernetes-in-codespaces)
  - Repeat until you are comfortable with Codespaces, Kubernetes, Prometheus, Fluent Bit, Grafana, K9s, and our inner-loop process (everything builds on this)
- Go through the GitOps Automation [Quick Start](https://github.com/bartr/autogitops)
  - Repeat until you are comfortable (GitOps builds on this)

## Click on `Use this template` and create your GitOps repo

- Only clone the main branch
- Additional instructions reference your new GitHub repo

## Setup your GitHub PAT

> GitOps needs a PAT that can push to this repo

- Create a Personal Access Token (PAT) in your GitHub account
  - Grant repo and package access
  - You can use an existing PAT as long as it has permissions
  - <https://github.com/settings/tokens>

- Create a personal Codespace secret
  - <https://github.com/settings/codespaces>
  - Name: PAT
  - Value: your PAT
  - Grant access to this repo and any other repos you want

## Create a Codespace

- Create your Codespace from your new repo
  - Click on `Code` then click `New Codespace`

Once Codespaces is running:

> Make sure your terminal is running zsh - bash is not supported and will not work
>
> If it's running bash, exit and create a new terminal (this is a random bug in Codespaces)

## Validate your setup

> It is a best practice to close the first shell and start a new one - sometimes the shell starts before setup is complete

```bash

# check your PAT - the three values should be the same
# if PAT is not set correctly, delete this Codespace and follow the instructions above for setting up your PAT
echo $PAT
echo $AKDC_PAT
echo $GITHUB_TOKEN

# check your env vars
flt env

# output
AKDC_GITOPS=true
AKDC_PAT=yourPAT
AKDC_REPO=thisRepoTenant/thisRepoName

```

## Login to azure

- Run `az login`
  - Select your subscription if required

## Save your PAT

- The setup script uses this PAT to setup GitOps

```bash

echo "$AKDC_PAT" > "$HOME/.ssh/akdc.pat"
chmod 600 "$HOME/.ssh/akdc.pat"

```

## Create a single cluster fleet

- ` flt create -c your-cluster-name`
  - do not specify `--arc` if you are using a normal AIRS subscription
  - do not specify `--ssl` unless you have domain, DNS, and wildcard cert setup

## Check your Fleet

> flt is the fleet CLI provided by Retail Edge / Pilot-in-a-Box

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

```bash

cd apps/imdb

# check deploy targets (should be [])
flt targets list

# clear the targets if not []
flt targets clear

# add the central region as a target
flt targets add yourClusterName

# deploy the changes
flt targets deploy

```

## Check that your GitHub Action is running

- <https://github.com/retaildevcrews/edge-gitops/actions>
  - your action should be queued or in-progress

## Action not running

- If your action is not running within 10-15 seconds
- Verify that the Action is enabled

## Check deployment

- Once the action completes successfully

```bash

# force flux to sync
flt sync

# check that imdb is deployed to central
flt check app imdb

```

## Setup your Azure Subscription

- If you plan to use Azure Arc or HCI
  - Request a `sponsored subscription` from AIRS
- todo - additional setup is required
  - domain name
  - DNS
  - SSL wildcard cert
  - Managed Identity
  - Key Vault
  - Service Principal

## Create a Fleet

- Create a [Fleet](docs/CreateFleet.md)

## Observability

- Retail Edge provides logs, metrics, and dashboards out of the box
- The setup is currently "semi-automated"
- [Observability](docs/Observability.md) setup

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
