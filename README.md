# gcp-bootstrap

Bootstrap development in *Google Cloud Platform (GCP)*.

This script creates a GCP Project and initializes a service account for Terraform.

This user will be assigned the necessary permissions that Terraform will require to manage infrastructure.

## Prerequisites

These scripts require the following:

- An existing *Google Organization Resource* ([link](https://cloud.google.com/resource-manager/docs/creating-managing-organization))
- An existing and valid / current *Billing Account*  ([link](https://cloud.google.com/billing/docs/how-to/create-billing-account))

## Scripts

Summary of the available scripts and their usage. Details available within each script.

| Script      | Description |
| ----------- | ----------- |
| **create_gcp_environment.sh** | Initialize a new *GCP Project* along with an initial *Terraform* identity. |
| **delete_gcp_environment.sh** | Delete a GCP Project and disable its billing. |
| **login.sh** | Log in or refresh Google Cloud *credentials* so scripts can be executed. |
| **lint.sh** | Lint the codebase. |
| **set_terraform_roles.sh** | Set the Terraform roles for a GCP Project. |
| **util.sh** | A set of utilities reusable across scripts. |

## Usage

Summary of project usage.


### 1. Establish Authentication Context

First, the authentication needs to be established so we have the ability to **interact** with *Google Cloud Platform (GCP)*.

The `login.sh` script logs in or refreshes Google Cloud *credentials* so scripts can be executed.

```sh
login.sh
```

An example of script execution.

```sh
scripts/login.sh 
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=32555940559.apps.googleusercontent.com ...

You are now logged in as [person@company.com].
Your current project is [None].  You can change this setting by running:
  $ gcloud config set project PROJECT_ID
```

### 2. Create GCP Project

Next, a Google Cloud Platform (GCP) **project** needs to be created. *Projects* are used to isolate and organize infrastructure.

This is accomplished by executing the `create_gcp_environment.sh` script.

This script creates a new *GCP Project* and initializes it with an initial *Terraform* identity. 

```sh
create_gcp_environment.sh --project <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing <BILLING_ACCOUNT_ID>
# OR
# create_gcp_environment.sh -p <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>
```

An example of script execution.

```sh
scripts/create_gcp_environment.sh --project test-gcp-scripts --organization $ORGANIZATION_ID --billing $BILLING_ACCOUNT

[2025-06-04T23:19:37-0400] [INFO]: Project Name  : test-gcp-scripts
[2025-06-04T23:19:37-0400] [INFO]: Organization  : 105637539410
[2025-06-04T23:19:37-0400] [INFO]: Billing       : 0181BD-E8A62D-6B2069
[2025-06-04T23:19:37-0400] [INFO]: Debug         : warning
[2025-06-04T23:19:37-0400] [INFO]: Creating project: test-gcp-scripts-1749093577
[2025-06-04T23:19:49-0400] [INFO]: Successfully created project: test-gcp-scripts-1749093577
[2025-06-04T23:19:49-0400] [INFO]: Setting active project to: test-gcp-scripts-1749093577
[2025-06-04T23:19:50-0400] [INFO]: Successfully set active project: test-gcp-scripts-1749093577
[2025-06-04T23:19:50-0400] [INFO]: Linking billing account: 0181BD-E8A62D-6B2069
[2025-06-04T23:19:53-0400] [INFO]: Successfully linked billing account: 0181BD-E8A62D-6B2069
Enabling Service APIs: 
Enabling API: cloudresourcemanager.googleapis.com
Successfully enabled API: cloudresourcemanager.googleapis.com
Enabling API: iam.googleapis.com
Successfully enabled API: iam.googleapis.com
[2025-06-04T23:20:05-0400] [INFO]: Project creation complete: test-gcp-scripts
```

### 3. Create Terraforrm User

Now that a GCP Project exists, an identity for the **Terraform User** will be required.

This user will facilitate the *interactions* between ***Terraform*** and ***Google Cloud Platform***, created using the `create_service_accounts.sh` script.

An example of script execution.

```sh
scripts/create_service_accounts.sh --project test-gcp-scripts-1749093577 --organization $ORGANIZATION_ID --billing $BILLING_ACCOUNT
[2025-06-05T00:15:14-0400] [INFO]: Project Name  : test-gcp-scripts-1749093577
[2025-06-05T00:15:14-0400] [INFO]: Organization  : 105637539410
[2025-06-05T00:15:14-0400] [INFO]: Billing       : 0181BD-E8A62D-6B2069
[2025-06-05T00:15:14-0400] [INFO]: Debug         : warning
[2025-06-05T00:15:14-0400] [INFO]: Setting active project to: test-gcp-scripts-1749093577
[2025-06-05T00:15:15-0400] [INFO]: Successfully set active project: test-gcp-scripts-1749093577
[2025-06-05T00:15:15-0400] [INFO]: Service Accounts: terraform
[2025-06-05T00:15:15-0400] [INFO]: Creating service accounts: terraform-test-gcp-scripts-1749093577.key
WARNING: The following filter keys were not present in any resource : email
Created service account [terraform].
[2025-06-05T00:15:18-0400] [INFO]: Successfully created service account: terraform
```

### 4. Create Terraform User Key

A *Service Account Key* will be used to authenticate via the **GOOGLE_APPLICATION_CREDENTIALS** environment variable within the environment of your choosing (i.e., local, Terraform Cloud).

The `create_service_account_keys.sh` script is responsible for generating the key.
 
```sh
scripts/create_service_account_keys.sh --project test-gcp-scripts-1749093577 --organization $ORGANIZATION_ID --billing $BILLING_ACCOUNT
[2025-06-05T01:12:39-0400] [INFO]: Project Name  : test-gcp-scripts-1749093577
[2025-06-05T01:12:39-0400] [INFO]: Organization  : 105637539410
[2025-06-05T01:12:39-0400] [INFO]: Billing       : 0181BD-E8A62D-6B2069
[2025-06-05T01:12:39-0400] [INFO]: Debug         : warning
[2025-06-05T01:12:39-0400] [INFO]: Setting active project to: test-gcp-scripts-1749093577
[2025-06-05T01:12:40-0400] [INFO]: Successfully set active project: test-gcp-scripts-1749093577
[2025-06-05T01:12:40-0400] [INFO]: Service Accounts: terraform
[2025-06-05T01:12:40-0400] [INFO]: Creating service account keys: terraform-test-gcp-scripts-1749093577.key
created key [e789d53965bbd378ec85ac61966cbd80037626e0] of type [json] as [terraform-test-gcp-scripts-1749093577.key] for [terraform@test-gcp-scripts-1749093577.iam.gserviceaccount.com]
[2025-06-05T01:12:42-0400] [INFO]: Successfully created service account key: terraform
```

The key's contents can be extracted via `jq` for input as the **GOOGLE_APPLICATION_CREDENTIALS** environment variable.

```sh
cat terraform-test-gcp-scripts-1749093577.key | jq -c
```

## Miscellaneous

Summary of other available *scripts*.

### Delete a Google Cloud Platform (GCP) Project

The `delete_gcp_environment.sh` script deletes a *GCP Project* and disable its *Billing*.

```sh
delete_gcp_environment.sh <PROJECT_ID>
```

An example of script execution.

```sh
scripts/delete_gcp_environment.sh test-gcp-scripts-1734666480
Deleting project: test-gcp-scripts-1734666480
Successfully deleted project: test-gcp-scripts-1734666480
Unlinking project billing: test-gcp-scripts-1734666480
Successfully unlinked project billing: test-gcp-scripts-1734666480
```

An example of script execution.

```sh
scripts/delete_vm.sh --name instance-1734678191 --zone us-central1-a --project test-gcp-scripts-1734665851
Project : test-gcp-scripts-1734665851
Name    : instance-1734678191
Zone    : us-central1-a
Debug   : warning
Executing script: scripts/delete_vm.sh
GCP project: test-gcp-scripts-1734665851
Deleted [https://www.googleapis.com/compute/v1/projects/test-gcp-scripts-1734665851/zones/us-central1-a/instances/instance-1734678191].
```

### Set / Update Terraform Roles

The `set_terraform_roles.sh` script sets the *Terraform* roles / permissions for a *GCP Project*. It can be executed any number of times to update a project.

```sh
set_terraform_roles.sh <PROJECT_ID>
```

An example of script execution.

```sh
scripts/set_terraform_roles.sh test-gcp-scripts-1727577182
Executing script: scripts/set_terraform_roles.sh
Refreshing Terraform roles: test-gcp-scripts-1727577182
Removing Existing Role(s): Terraform User
Updated IAM policy for project [test-gcp-scripts-1727577182].
bindings:
- members:
  - serviceAccount:92332032410@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:terraform@test-gcp-scripts-1727577182.iam.gserviceaccount.com
  role: roles/cloudbuild.builds.editor
```