# Retail Edge Onboarding

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Platform Team Contacts

- anflinch
- bartr
- devwag
- kevinshah
- wabrez

## Work in Progress - todo

- run ssh-keygen to generate id_rsa if not exists
- login to azure
- create Managed Identity
- Save your PAT (use PAT if set - explain why)
- `echo "$GITHUB_TOKEN" > "$HOME/.ssh/akdc.pat"
- `chmod 600 "$HOME/.ssh/akdc.pat"
- create a single cluster fleet


## Onboarding

- Request a test fleet from the Platform Team
- Follow the [instructions](https://github.com/cse-labs/moss) and join the `Microsoft` and `cse-labs` GitHub orgs
- Request an invitation to the RetailDevCrews GitHub Org from the platform team
  - Accept the invitation
- Validation repos
  - If you get a 403 or 404 error make sure you joined the org / accepted your invite
  - <https://github.com/cse-labs/private-test>
  - <https://github.com/retaildevcrews/private-test>
- Go through the Kubernetes in Codespaces inner-loop hands-on lab [here](https://github.com/cse-labs/kubernetes-in-codespaces)
  - Repeat until you are comfortable with Codespaces, Kubernetes, Prometheus, Fluent Bit, Grafana, K9s, and our inner-loop process (everything builds on this)
- Go through the GitOps Automation [Quick Start](https://github.com/bartr/autogitops)
  - Repeat until you are comfortable (GitOps builds on this)

## Setup your GitHub PAT

> We use multiple GitHub Repos, so you have to use a PAT

- Create a Personal Access Token (PAT) in your GitHub account
  - Grant repo and package access
  - You can use an existing PAT as long as it has permissions
  - <https://github.com/settings/tokens>

- Grant SSO access to the token
  - cse-labs
  - retaildevcrews
  - Any other tenant you choose

- Create a personal Codespace secret
  - <https://github.com/settings/codespaces>
  - Name: PAT
  - Value: your PAT
  - Grant access to this repo and any other repos you want

## Create a Codespace

> Since we use GitHub secrets, do not fork the repo or you won't get the secrets and nothing will work

- Create your Codespace from the main branch
  - Click on `Code` then click `New Codespace`

Once Codespaces is running:

> Make sure your terminal is running zsh - bash is not supported and will not work
>
> If it's running bash, exit and create a new terminal (this is a random bug in Codespaces)

## Test Fleet

- Request a test fleet from the Platform Team
- Once your fleet is created, the Platform Team will provide the branch name
- Do all of your work in this branch
- Do not PR your branch to main
- Do not use other branches
  - These branches are used for customer demos
  - Some CLI commands can change behavior

### Checkout your branch

  ```bash

  # you should already be in this directory
  cd /workspaces/edge-gitops
  git pull
  git checkout yourBranchName
  git pull

  ```

## Sync Your Branch With Main Branch

> FleetReadme.md is a fleet specific doc and is not synched with main

- The following directories are automatically synched with the main branch when you start a Codespace
  - README.md
  - docs
  - .devcontainer
  - .github
- You can manually sync by running `.devcontainer/sync-main-branch.sh` from Codespaces
- The changes are not committed or pushed to your repo to avoid overwriting files
  - You should commit and push the changes after reviewing
- You can control what is synced by modifying
  - .devcontainer/post-start.sh
  - .devcontainer/sync-main-branch.sh

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

> Note that the create, delete, and groups commands will not work unless you have been granted additional access

## Deploy the Reference App

- IMDb is the reference app

### If you get a 403 error from `flt targets deploy`, your PAT isn't setup correctly

```bash

cd apps/imdb

# check deploy targets (should be [])
flt targets list

# clear the targets if not []
flt targets clear

# add the central region as a target
flt targets add region:central

# deploy the changes
flt targets deploy

```

## Check that your GitHub Action is running

- <https://github.com/retaildevcrews/edge-gitops/actions>
  - your action should be queued or in-progress

## Action not running

- If your action is not running within 10-15 seconds
- Verify that your PAT has sufficient permissions

### Make sure your PAT has the correct permissions and is authorized for SSO in the orgs

  ```bash

  # try pushing manually
  git push

  ```

## Check deployment

- Once the action completes successfully

```bash

# force flux to sync
flt sync

# check that imdb is deployed to central
flt check app imdb

```

## Create and Deploy a New App

- Create a TestApp from the dotnet WebAPI template
  - Deploy and test in inner-loop
  - Deploy and test on the fleet

```bash

# start in the apps directory
cd /workspaces/edge-gitops/apps
git pull

# make sure git is "clean"
#  commit / push as needed
git status

# create a new dotnet WebAPI app
# you can use any app name as long as it is PascalCaseAlpha
# if you use a different app name, you will have to make the docker image public (bug)
#   you have to be an owner of github/retaildevcrews to do this
#   or change ci-cd / autogitops.json to point to a ghcr that you control
# if in doubt, use TestApp or MyApp
flt new dotnet webapi TestApp

# change to the testapp directory
cd testapp

```

## Deploy to the fleet

> Start in apps/testapp dir

```bash

# set the target to west region and deploy via GitOps
flt targets clear
flt targets add region:west
flt targets deploy

# wait for ci-cd to finish

# check for the new namespace
flt sync
flt check app testapp

# undeploy testapp
git pull
flt targets clear
flt targets deploy

# wait for ci-cd to finish
flt sync

# it will take a few seconds for the ns to be deleted
flt check app testapp

```

## inner-loop

> Start in apps/testapp dir

- Remove apps if necessary

  ```bash

  # check the pods
  kic pods

  # if any pods are running app, monitoring, or logging recreate the cluster
  kic cluster create

  ```

- Build and deploy TestApp

> Start in apps/testapp dir

  ```bash

  git pull

  # build test app
  kic app build

  # rebuild cluster and deploy testapp + webv
  kic app deploy

  # wait for pods to start
  kic pods

  # check the app
  kic check app

  # check all
  kic check all

  # run tests
  kic test load &
  kic test integration

  ```

## Clean up

```bash

# start in the apps directory
cd /workspaces/edge-gitops/apps

# remove test app
git pull
rm -rf testapp
git commit -am "removed testapp"
git push

# your repo should be "clean"

# re-create the cluster
kic cluster create

```

## Setup your GitOps Repo

- Our GitOps repo is shared for ease of evaluating
- At some point, you will want your own GitOps repo for security and isolation
- Setup a new [GitOps repo](docs/GitOpsRepo.md)

## Setup your Azure Subscription

- Like our GitOps repo, our Azure subscription is shared for ease of evaluating
- You will want to setup your own Azure subscription
- If you plan to use Azure Arc or HCI
  - Request a `sponsored subscription` from AIRS
- todo - work in progress

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
