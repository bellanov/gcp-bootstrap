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

## Examples

Various examples of script execution.

### create_gcp_environment.sh

This script creates a new *GCP Project* and initializes it with an initial *Terraform* identity. Projects are used to isolate and organize infrastructure.

```sh
create_gcp_environment.sh --project <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing <BILLING_ACCOUNT_ID>
# OR
# create_gcp_environment.sh -p <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>
```

An example of script execution.

```sh
scripts/create_gcp_environment.sh -p test-gcp-scripts -o "1234567890" -b "123ABCD-ABC1234-123ABCD"
Project Name  : test-gcp-scripts
Organization  : 1234567890
Billing       : 123ABCD-ABC1234-123ABCD
Debug         : warning
Creating project: test-gcp-scripts-1734665851
Successfully created project: test-gcp-scripts-1734665851
Setting active project to: test-gcp-scripts-1734665851
Successfully set active project: test-gcp-scripts-1734665851
Linking billing account: 123ABCD-ABC1234-123ABCD
Successfully linked billing account: 123ABCD-ABC1234-123ABCD
Enabling Service APIs: Cloud Resource Manager, Identity & Access Management, Secret Manager API
Enabling API: cloudresourcemanager.googleapis.com
Successfully enabled API: cloudresourcemanager.googleapis.com
...
```

### delete_gcp_environment.sh

This script deletes a *GCP Project* and disable its *Billing*.

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

### login.sh

This script logs in or refreshes Google Cloud *credentials* so scripts can be executed.

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

### set_terraform_roles.sh

This script sets the *Terraform* roles / permissions for a *GCP Project*. It can be executed any number of times to update a project.

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