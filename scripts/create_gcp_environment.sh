#!/bin/bash
#
# Create a GCP Project to isolate infrastructure.
#
#   Usage:
#     create_gcp_environment.sh --name <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing-account <BILLING_ACCOUNT_ID>
#     create_gcp_environment.sh -n <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>
#

# Project Configuration
TIMESTAMP="$(date +%s)"
SERVICE_APIS="Cloud Resource Manager, Identity & Access Management, Secret Manager API"
APIS="cloudresourcemanager.googleapis.com compute.googleapis.com dns.googleapis.com iam.googleapis.com"
SERVICE_ACCOUNTS="terraform"

# Exit on error
set -e

#######################################
# Display an error message to STDERR.
# Globals:
#   None
# Arguments:
#   String containing the error message.
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

#######################################
# Validate the arguments and initialize the script.
# Globals:
#   None.
# Arguments:
#   None.
#######################################
initialize() {

  # Validate the GCP Project argumeent
  if [ "$1" = "" ] ; then
    err "Error: PROJECT_NAME not provided or is invalid."
  fi

  # Validate the Organization argument
  if [ "$2" = "" ] ; then
    err "Error: ORGANIZATION not provided or is invalid."
  fi

  # Validate the Billing argument
  if [ "$4" = "" ] ; then
    err "Error: BILLING_ACCOUNT not provided or is invalid."
  fi

  # Initialize Verbosity
  if [ "$3" = "1" ] ; then
    debug="debug"
  else
    debug="warning"
  fi

  # Display validated arguments / parameters
  echo "Project Name  : $1"
  echo "Organization  : $2"
  echo "Billing       : $4"
  echo "Debug         : $debug"

}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -o|--organization) organization="$2"; shift ;;
      -b|--billing) billing="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$organization" "$debug" "$billing"

# Establish Project Id
project_id="${project}-${TIMESTAMP}"

# Create the Project
echo "Creating project: ${project_id}"

if gcloud projects create "${project_id}" \
  --organization="${organization}" \
  --name="${project}" >/dev/null 2>&1; then
  echo "Successfully created project: ${project_id}"
else
  err "Error: Failed to create project: ${project_id}"
fi

# Set the project as the active
echo "Setting active project to: ${project_id}"

if gcloud config set project "${project_id}" >/dev/null 2>&1; then
  echo "Successfully set active project: ${project_id}"
else
  err "Error: Failed to set the active project: ${project_id}"
fi

# Link the billing account to the project
echo "Linking billing account: ${billing}"

if gcloud beta billing projects link "${project_id}" \
  --billing-account "${billing}" >/dev/null 2>&1; then
  echo "Successfully linked billing account: ${billing}"
else
  err "Error: Failed to link billing account: ${billing}"
fi

# Enable the required services within the project
echo "Enabling Service APIs: ${SERVICE_APIS}"

for API in $APIS
do
  echo "Enabling API: ${API}"
  
  if gcloud services enable "${API}" >/dev/null 2>&1; then
    echo "Successfully enabled API: ${API}"
  else
    err "Error: Failed to enable API: ${API}"
  fi
done

# Create the service accounts
echo "Service Accounts: ${SERVICE_ACCOUNTS}"
for SERVICE_ACCOUNT in $SERVICE_ACCOUNTS
do
  echo "Creating service accounts & keys: ${SERVICE_ACCOUNT}-${project_id}.key"

  if gcloud iam service-accounts create "${SERVICE_ACCOUNT}" >/dev/null 2>&1; then
    echo "Successfully created service account: ${SERVICE_ACCOUNT}"
  else
    err "Error: Failed to create service account: ${SERVICE_ACCOUNT}"
  fi
  
  # Give the service account enough time to be created
  sleep 5
  
  # Create the service account key
  gcloud iam service-accounts keys create "${SERVICE_ACCOUNT}-${project_id}.key" \
    --iam-account="${SERVICE_ACCOUNT}@${project_id}.iam.gserviceaccount.com"
done

# Assign the necessary roles to the Terraform user
ROLES="roles/owner roles/storage.admin roles/iam.serviceAccountAdmin"

echo "Assigning User Role(s): Terraform User"

for ROLE in $ROLES
do
  if gcloud projects add-iam-policy-binding "${project_id}" \
    --member=serviceAccount:terraform@"${project_id}".iam.gserviceaccount.com \
    --role="${ROLE}" >/dev/null 2>&1; then
    echo "Successfully attached role: ${ROLE}"
  else
    err "Error: Failed to attach role: ${ROLE}"
  fi
done

# Project Creation Complete
echo "Project creation complete: ${project_id}"
