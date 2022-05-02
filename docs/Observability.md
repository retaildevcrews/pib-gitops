# Observability

To monitor our fleet, we deploy a central monitoring cluster with fluent bit and prometheus configured to send logs and metrics to Grafana Cloud. The monitoring cluster runs WebValidate (WebV) to send requests to apps running on the other clusters in the fleet. The current design has one deployment of WebV for each app. For instance, the webv-heartbeat deployment sends requests to all of the heartbeat apps running on the fleet clusters.  Fluent Bit is configured to forward WebV logs to Grafana Loki and prometheus is configured to scrape WebV metrics.  These logs and metrics are used to power a Grafana Cloud dashboard and provide insight into cluster and app availability and latency.

## Prerequisites

* Grafana Cloud Account
* Azure subscription
* Managed Identity (MI) for the fleet
* Key Vault
  * Must be named kv-tld
  * Grant the MI access to the Key Vault

## Key Vault Secrets

### Fluent Bit Secret

Follow instructions [here](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/fluent-bit#create-fluent-bit-secret) to create the required Fluent Bit secret in the kv-tld Key Vault.

### Prometheus Secret

Follow instructions [here](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/fluent-bit#create-fluent-bit-secret) to create the required Prometheus secret in the kv-tld Key Vault.

### Execution

The Key Vault secret values are retrieved (via MI) during fleet creation and stored as kubernetes secrets on each cluster in the fleet (in [fleet-vm.templ](https://github.com/retaildevcrews/akdc/blob/main/bin/.flt/fleet-vm.templ) and [akdc-pre-flux.sh](https://github.com/retaildevcrews/akdc/blob/main/vm/setup/akdc-pre-flux.sh#L23)). Additionally, the fluent-bit and prometheus namespaces are bootstrapped on each of the clusters (prior to secret creation).

## Deploy a central monitoring cluster to your fleet

- You need additional permissions to create a fleet
  - Contact the Platform Core Team for access
    - anflinch
    - bartr
    - devwag
    - kevinshah
    - wabrez

- Checkout your fleet branch
- Name your fleet

  ```bash

  # must be unique
  flt groups | grep fleet | sort

  # 10 chars max
  # lowercase alpha and - only
  # must begin and end with alpha
  #### bad names will fail later ###
  export FLT_NAME=yourAliasOrProjectName

  ```

- Create corp-monitoring cluster

  ```bash

  # must be named corp-monitoring-[your fleet name]
  flt create --gitops --ssl cseretail.com -g $FLT_NAME-fleet -c corp-monitoring-$FLT_NAME

  ```

## WebV

### Add WebV to apps/ directory

Copy the [WebV directory](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/webv) to the apps/ directory in your fleet branch. By default, this provides you with two deployments of webv: webv-heartbeat and webv-imdb. If you do not have the imdb app deployed to any stores in your fleet, it is recommended to not include the imdb.yaml file in your branch.

### Configure WebV

Follow the instructions [here](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/webv#web-validate-webv-setup) to update the contents of the heartbeat.yaml and/or imdb.yaml file.

### Update targets and deploy WebV to corp-monitoring cluster

```bash

# make sure you are in the webv directory in your fleet branch
cd apps/webv

# should be empty
flt targets list

# clear if needed
flt targets clear

# add corp monitoring cluster
flt targets add corp-monitoring-$FLT_NAME

flt targets deploy

```

## Fluent Bit

### Add Fluent Bit to apps/ directory

Copy the [fluent-bit directory](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/fluent-bit) to the apps/ directory in your fleet branch.

### Configure Fluent Bit

Follow the instructions [here](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/fluent-bit#update-fluent-bit-config) to configure the Fluent Bit deployment.

### Update targets and deploy Fluent Bit to corp-monitoring cluster

```bash

# make sure you are in the fluent-bit directory
cd apps/fluent-bit

# should be empty
flt targets list

# clear if needed
flt targets clear

# add corp monitoring cluster
flt targets add corp-monitoring-$FLT_NAME

flt targets deploy

```

## Prometheus

### Add Prometheus to apps/ directory

Copy the [prometheus directory](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/prometheus) to the apps/ directory in your fleet branch.

### Configure Prometheus

Follow the instructions [here](https://github.com/retaildevcrews/edge-gitops/tree/apps/apps/prometheus#update-prometheus-config) to configure the Prometheus deployment.

### Update targets and deploy Prometheus to corp-monitoring cluster

```bash

# make sure you are in the prometheus directory
cd apps/prometheus

# should be empty
flt targets list

# clear if needed
flt targets clear

# add corp monitoring cluster
flt targets add corp-monitoring-$FLT_NAME

flt targets deploy

```

## Create Grafana Cloud Dashboard

```bash

# generate json based on dashboard-template
cp dashboard-template.json dashboard.json
sed -i "s/%%FLEET_NAME%%/${FLT_NAME}/g" dashboard.json

```

Copy the content in dashboard.json and import as a new dashboard in Grafana Cloud.

## Create Alert for New Fleet

* Go to Grafana Cloud > Alerting > Alert Rules.
* Create a new alert (+ New Alert Rule).
  * Name the rule $FLT_NAME App Issue
  * Rule type: Grafana managed alert
  * Folder: Platform
  * Group: $FLT_NAME - App Issue

* Under "Create a query to be alerted on":
  * For Query A:
    * Select grafanacloud.retailedge.prom as the source from the drop down list.
    * Replace {your $FLT_NAME} with your fleet name and copy the query below to the query field.
  * For Query B:
    * Set Operation to Reduce
    * Set Function to Last
    * Set Input to A
    * Leave Mode as Strict
  * Add another Expression (+ Expression)
    * Name the Expression "More than 5% errors"
    * Set Operation to Math
    * Type in the Expression: $B > 5
* Under "Define alert conditions"
  * Set Condition to "More than 5% errors"
  * Set evaluate every to 30s
  * Set for to 1m

Alert Query:

```sql

sum(rate(WebVDuration_count{status!="OK",server!="",origin_prometheus="corp-monitoring-{your $FLT_NAME}"}[10s])) by (server,job) / sum(rate(WebVDuration_count{server!="",origin_prometheus="corp-monitoring-{your $FLT_NAME}"}[10s])) by (server,job) * 100

```
