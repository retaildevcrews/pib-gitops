# Setup a new GitOps Repo

## Create a new repo

- todo - convert repo into template and create from template
  - is there a way to automate the updates from a template?
- Fork retaildevcrews/edge-gitops
  - Only fork the main branch
  - The repo can be public or private
- Enable the GitHub Action

## Using GitHub Web Editor

- Modify .devcontainer/on-create.sh
  - Replace the following
    - export AKDC_MI=yourManagedIdentity
    - export AKDC_REPO=yourOrg/yourGitOpsRepo
    - export AKDC_SSL=your-domain.com
    - export AKDC_VM_REPO=gitops
    - export PATH="$PATH:$(dirname "$REPO_BASE")/bin"
  - Commit changes

## Add GitHub Azure Secrets

> Make sure to enable the new repo for each secret

- todo - assumes you are using ours for now
  - Contact the platform team for AKDC_* values for our subscription
- Add the following personal GitHub secrets
  - PAT         - your GitHub PAT with repo and package permissions
  - AKDC_TENANT - Azure tenant ID
  - AKDC_SP_ID  - Azure Service Principal ID
  - AKDC_SP_KEY - Azure Service Principal Key
- Login to Azure and make sure you have permissions

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

## Repo Setup

- Open the repo in Codespaces to complete the rest of the setup
- Add /bin and /vm from retaildevcrews/akdc main branch

  ```bash

  cd ..
  git clone https://github.com/retaildevcrews/akdc
  cp -R akdc/bin $REPO_BASE
  cp -R akdc/vm $REPO_BASE
  rm -rf akdc
  cd $REPO_BASE

  ```

## Setup Bug

- Run the following commands to fix completions
- Exit and restart terminal

  ```bash

  flt completion zsh > $HOME/.oh-my-zsh/completions/_flt
  flux completion zsh > $HOME/.oh-my-zsh/completions/_flux
  k3d completion zsh > $HOME/.oh-my-zsh/completions/_k3d
  kic completion zsh > $HOME/.oh-my-zsh/completions/_kic
  kubectl completion zsh > $HOME/.oh-my-zsh/completions/_kubectl

  echo "cluster*" > .gitignore

  exit

  ```

## Commit and Push to your repo

- Run `git add, commit and push`

  ```bash

  git pull
  git add .
  git commit -am "added cli"
  git push

  ```

## Validate Codespace

- Make sure `kic` and `flt` run
- Check tab completion on `kic` and `flt`
- Run `flt env`
  - Validate env vars
- Login to Azure
  - `flt az login`
    - This will fail if your Azure secrets are not set correctly
- todo - work in progress

## Create a test fleet

> You have to be logged into Azure correctly

- Create a branch

```bash

git pull
git checkout -b my-fleet
git push -u origin my-fleet

```

## Test GitOps Automation

- Make sure the GitHub Action is enabled

  ```bash

  git pull

  # cluster name must be unique
  flt create -c my-test-cluster-101 --gitops-only

  # check the action to make sure it runs correctly

  # after the action completes, you should see deploy/apps and deploy/bootstrap files created
  git pull

  ```

- Create a one node test fleet

```bash

# make sure to start in the root of your GitOps repo
cd $REPO_BASE

# cluster name must be unique
flt create --gitops --ssl $AKDC_SSL -c my-test-cluster-101

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
    - Retry if you get a timeout
    - Run the command until you get `complete`

    ```bash

    flt check setup

    ```

- Check heartbeat and flux

  ```bash

  flt check flux

  # 0123456789ABCDEF0 my-test-cluster-101
  flt check heartbeat

  ```

## Clean up

- Delete the cluster

  ```bash

  flt delete my-test-cluster-101

  ```

- Delete the branch

  ```bash

  git checkout main
  git branch -D my-fleet
  git push origin --delete my-fleet
  git pull

  ```

## Setup GitHub `pre-build`

- Turn on pre-build from the portal
  - This is optional and recommended
    - Wait until everything is working before enabling pre-build
  - CODESPACES_PREBUILD_TOKEN
    - A GitHub PAT with repo and package permissions
      - Repo secret works
        - It cannot be a personal secret
        - todo - I'm not sure if this can be an `org secret` or has to be a `repo secret`
