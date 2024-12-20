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

```sh
create_gcp_environment.sh --project <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing <BILLING_ACCOUNT_ID>
# OR
# create_gcp_environment.sh -p <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>

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

### create_subnet.sh

This script creates a *Subnet*.

```sh
create_subnet.sh --name <SUBNET_NAME> --network <NETWORK_NAME> --ip-range <IP_RANGE> --region <REGION> --project <PROJECT_ID>
# OR
# create_subnet.sh -n <SUBNET_NAME> -net <NETWORK_NAME> -ipr <IP_RANGE> -r <REGION> -p <PROJECT_ID>

scripts/create_subnet.sh --name subnet-1 --network demo-vpc-1 --ip-range "10.1.0.0/16" --region us-central1 --project test-gcp-scripts-1734665851
Project : test-gcp-scripts-1734665851
Name    : subnet-1
Debug   : warning
Network : demo-vpc-1
Range   : 10.1.0.0/16
Region  : us-central1
Executing script: scripts/create_subnet.sh
GCP project: test-gcp-scripts-1734665851
Setting active project to: test-gcp-scripts-1734665851
Successfully set active project: test-gcp-scripts-1734665851
```

### create_vm.sh

This script creates a *Virtual Machine*.

```sh
create_vm.sh --subnet <SUBNET> --zone <ZONE> --project <PROJECT_ID>
# OR
# create_vm.sh -s <SUBNET> -z <ZONE> -p <PROJECT_ID>

scripts/create_vm.sh --subnet subnet-1 --zone us-central1-a --project test-gcp-scripts-1734665851

Project : test-gcp-scripts-1734665851
Zone    : us-central1-a
Subnet  : subnet-1
Debug   : warning
Executing script: scripts/create_vm.sh
GCP project: test-gcp-scripts-1734665851
Created [https://www.googleapis.com/compute/v1/projects/test-gcp-scripts-1734665851/zones/us-central1-a/instances/instance-1734678191].
NAME                 ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
instance-1734678191  us-central1-a  e2-micro      true         10.1.0.2     34.59.44.65  RUNNING
```

### delete_gcp_environment.sh

This script deletes a *GCP Project* and disable its *Billing*.

```sh
delete_gcp_environment.sh <PROJECT_ID>

scripts/delete_gcp_environment.sh test-gcp-scripts-1734666480
Deleting project: test-gcp-scripts-1734666480
Successfully deleted project: test-gcp-scripts-1734666480
Unlinking project billing: test-gcp-scripts-1734666480
Successfully unlinked project billing: test-gcp-scripts-1734666480
```

### delete_vpc.sh

This script *deletes* a VPC.

```sh
delete_vpc.sh --name <VPC_NAME> --rules <FIREWALL_RULES> --project <PROJECT_ID>
# OR
# delete_vpc.sh -n <VPC_NAME> -r <FIREWALL_RULES> -p <PROJECT_ID>

scripts/delete_vpc.sh --name demo-vpc-1 --project test-gcp-scripts-1734665851 --rules "allow-icmp allow-ssh"
Project         : test-gcp-scripts-1734665851
VPC             : demo-vpc-1
Firewall Rules  : allow-icmp allow-ssh
Debug           : warning
Executing script: scripts/delete_vpc.sh
Project: test-gcp-scripts-1734665851
Deleted [https://www.googleapis.com/compute/v1/projects/test-gcp-scripts-1734665851/global/networks/demo-vpc-1].
```

### delete_vm.sh

This script deletes a *Virtual Machine*.

```sh
delete_vm.sh --name <INSTANCE_NAME> --project <PROJECT_ID> --zone <ZONE.
# OR
# delete_vm.sh -n <INSTANCE_NAME> -p <PROJECT_ID> -z <ZONE>

scripts/delete_vm.sh --name instance-1734678191 --zone us-central1-a --project test-gcp-scripts-1734665851
Project : test-gcp-scripts-1734665851
Name    : instance-1734678191
Zone    : us-central1-a
Debug   : warning
Executing script: scripts/delete_vm.sh
GCP project: test-gcp-scripts-1734665851
Deleted [https://www.googleapis.com/compute/v1/projects/test-gcp-scripts-1734665851/zones/us-central1-a/instances/instance-1734678191].
```

### disable_apis.sh

This script disables *Service APIs* in a *GCP Project*.

```sh
disable_apis.sh <PROJECT_ID>

scripts/disable_apis.sh test-gcp-scripts-1734665851
Project: test-gcp-scripts-1734665851
Disabling API: cloudresourcemanager.googleapis.com
Successfully disabled API: cloudresourcemanager.googleapis.com
Disabling API: compute.googleapis.com
Successfully disabled API: compute.googleapis.com
Disabling API: iam.googleapis.com
Successfully disabled API: iam.googleapis.com
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
login.sh

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