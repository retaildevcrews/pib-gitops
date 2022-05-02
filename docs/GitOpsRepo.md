# Setup a new GitOps Repo

## Create a new repo

- Create a new repo from this template: `retaildevcrews/gitops-template`
  - Only clone the main branch
  - The repo can be public or private
- Enable the GitHub Action
  - In `Settings / Actions`
    - Enable read/write to GitHub Token

## Using GitHub Web Editor

> You can skip this step if you're using `cseretail.com`

- Modify .devcontainer/on-create.sh
  - Replace the following
    - export AKDC_SSL=your-domain.com
  - Commit changes

## Add GitHub Azure Secrets

> Make sure to enable the new repo for each secret

- Contact the platform team for AKDC_* values for our subscription
- Add the following personal GitHub secrets
  - PAT         - your GitHub PAT with repo and package permissions
  - AKDC_TENANT - Azure tenant ID
  - AKDC_SP_ID  - Azure Service Principal ID
  - AKDC_SP_KEY - Azure Service Principal Key

## Add Codespaces Secrets

> Make sure you have SSH keys - create if necessary
>
> `ll $HOME/.ssh` - id_rsa and id_rsa.pub

- Add the following secrets
  - Secrets can be `org secrets` or `repo secrets`
  - AKDC_PAT
    - A GitHub PAT with repo and package permissions
  - AKDC_ID_RSA
    - `cat $HOME/.ssh/id_rsa | base64 -w 0`
      - Make sure not to include the `%` on the end
  - AKDC_ID_RSA_PUB
    - `cat $HOME/.ssh/id_rsa.pub | base64 -w 0`
      - Make sure not to include the `%` on the end
  - AKDC_MI
    - Azure resource path to Managed Identity
      - /subscriptions/{miSubscription}/resourcegroups/{miRG}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{miName}

## Repo Setup

- Open the repo in Codespaces to complete the rest of the setup

## Validate Codespace

- Make sure `kic` and `flt` run
- Check tab completion on `kic` and `flt`
- Run `flt env`
  - Validate env vars
- Login to Azure
  - `flt az login`
    - This will fail if your Azure secrets are not set correctly

## Create a test fleet

> You have to be logged into Azure correctly

- Create a branch

```bash

# these have to be unique
export MY_FLEET=my-fleet
export MY_CLUSTER=my-test-cluster-101

git pull
git checkout -b $MY_FLEET
git push -u origin $MY_FLEET

```

## Test GitOps Automation

> You only have to do this step to test GitHub Actions

- Make sure the GitHub Action is enabled

  ```bash

  git pull

  # cluster name must be unique
  flt create -c $MY_CLUSTER --gitops-only

  # check the action to make sure it runs correctly

  # after the action completes, you should see deploy/apps and deploy/bootstrap files created
  git pull

  ```

- Create a one node test fleet

```bash

# make sure to start in the root of your GitOps repo
cd $REPO_BASE

# cluster name must be unique
flt create  -c $MY_CLUSTER

# update repo
git pull
git add .
git commit -am "added ips"
git push

```

## Verify test cluster

> It takes about 90 seconds for the flt create command to complete
>
> It takes another 4-5 minutes for the VM to bootstrap the cluster

- Check the setup status
  - This command will not work until the SSHD service starts on the VM
    - Retry if you get `Connection timed out`
    - Run the command until you get `complete`

    ```bash

    flt check setup

    ```

- Check flux and heartbeat

  ```bash

  flt check flux

  # 0123456789ABCDEF0 my-test-cluster-101
  flt check heartbeat

  ```

## Clean up

- Delete the cluster

  ```bash

  flt delete $MY_CLUSTER

  ```

- Delete the branch

  ```bash

  git checkout main
  git branch -D $MY_FLEET
  git push origin --delete $MY_FLEET
  git pull

  ```

## Setup GitHub `pre-build`

- Turn on pre-build from the portal
  - This is optional and recommended
    - Wait until everything is working before enabling pre-build
- Create a prebuild secret as a `repo secret`
  - CODESPACES_PREBUILD_TOKEN
    - A GitHub PAT with repo and package permissions
