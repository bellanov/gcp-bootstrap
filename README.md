# gcp-bootstrap

Bootstrap development in *Google Cloud Platform*.

## Prerequisites

These scripts require the following:

- An existing *Google Organization Resource* ([link](https://cloud.google.com/resource-manager/docs/creating-managing-organization))
- An existing and valid / current *Billing Account*  ([link](https://cloud.google.com/billing/docs/how-to/create-billing-account))


## Scripts

Summary of the available scripts and their usage. Details available within each script.

| Script      | Description |
| ----------- | ----------- |
| **args.sh** | Example of how to process command line arguments in BASH. |
| **create_gcp_environment.sh** | Initialize a new *GCP Project* along with an initial *Terraform* identity. |
| **create_subnet.sh** | Create a Subnet within a VPC. |
| **create_vm.sh** | Create a VM within a Subnet. |
| **create_vpc.sh** | Create a VPC to isolate network resources. |
| **delete_gcp_environment.sh** | Delete a GCP Project and disable its billing. |
| **delete_subnet.sh** | Delete a Subnet. |
| **delete_vm.sh** | Delete a Compute VM. |
| **delete_vpc.sh** | Delete a VPC. |
| **disable_apis.sh** | Disable Service APIs in a GCP Project. |
| **enable_apis.sh** | Enable Service APIs in a GCP Project. |
| **login.sh** | Log in or refresh Google Cloud *credentials* so scripts can be executed. |
| **lint.sh** | Lint the codebase. |
| **set_terraform_roles.sh** | Set the Terraform roles for a GCP Project. |

## Examples

Various examples of script execution.

### create_gcp_environment.sh

This script creates a new *GCP Project* and initializes it with an initial *Terraform* identity. Projects are used to isolate and organize infrastructure.

The script accepts 3 positional parameters, namely the desierd *GCP Project ID*, *Organization ID*, and *Billing Account*. The script also generates the *Service Account Key* for the *Terraform* identity. In this example,

```sh
create_gcp_environment.sh --name <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing-account <BILLING_ACCOUNT_ID>
# create_gcp_environment.sh -n <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>

scripts/create_gcp_environment.sh test-gcp-scripts "1234567890" "123ABCD-ABC1234-123ABCD"
Executing script: scripts/create_gcp_environment.sh
Creating project: test-1733954758
Successfully created project: test-1733954758
Setting active project to: test-1733954758
Successfully set active project: test-1733954758
Linking billing account: 0181BD-E8A62D-6B2069
Successfully linked billing account: 0181BD-E8A62D-6B2069
Enabling Service APIs: Cloud Resource Manager, Identity & Access Management, Secret Manager API
Enabling API: cloudresourcemanager.googleapis.com
Successfully enabled API: cloudresourcemanager.googleapis.com
...
```

### delete_gcp_environment.sh

This script deletes a *GCP Project* and disable its *Billing*.

```sh
delete_gcp_environment.sh <PROJECT_ID>

scripts/delete_gcp_environment.sh test-gcp-scripts-1727577182
Deleting project: test-gcp-scripts-1727577182
Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/test-gcp-scripts-1727577182].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete test-gcp-scripts-1727577182

See https://cloud.google.com/resource-manager/docs/creating-managing-projects for information on shutting down projects.
billingAccountName: ''
billingEnabled: false
name: projects/test-gcp-scripts-1727577182/billingInfo
projectId: test-gcp-scripts-1727577182
```

### enable_apis.sh

This script enables *Service APIs* in a *GCP Project*.

```sh
enable_apis.sh <PROJECT_ID>

scripts/enable_apis.sh test-gcp-scripts-1727577182
Executing script: scripts/enable_apis.sh
GCP project: test-gcp-scripts-1727577182
Enabling API: artifactregistry.googleapis.com
Enabling API: cloudbuild.googleapis.com
Enabling API: cloudresourcemanager.googleapis.com
Enabling API: compute.googleapis.com
```

### login.sh

This script logs in or refreshes Google Cloud *credentials* so scripts can be executed.

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