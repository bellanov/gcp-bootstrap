#!/bin/bash
#
# Create a GCP Project to isolate infrastructure.
#
#   Usage:
#       create_gcp_environment.sh <PROJECT_NAME> <ORGANIZATION_ID> <BILLING_ACCOUNT_ID>
#

PROJECT_NAME=$1
TIMESTAMP="$(date +%s)"
PROJECT_ID="${PROJECT_NAME}-${TIMESTAMP}"
ORGANIZATION_ID=$2
BILLING_ACCOUNT=$3
SERVICE_APIS="Artifact Registry, Cloud Build API, Cloud Resource Manager, Identity & Access Management, Secret Manager API"
APIS="artifactregistry.googleapis.com cloudbuild.googleapis.com cloudresourcemanager.googleapis.com iam.googleapis.com secretmanager.googleapis.com"
SERVICE_ACCOUNTS="terraform"

set -e  # Exit on error

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
#   PROJECT_NAME
#   ORGANIZATION_ID
#   BILLING_ACCOUNT
# Arguments:
#   None.
#######################################
initialize() {
  # Detect the presence of all arguments, otherwise exit
  if [ "$PROJECT_NAME" = "" ] || [ "$ORGANIZATION_ID" = "" ] || [ "$BILLING_ACCOUNT" = "" ] ; then
    err "Error: Arguments not provided or are invalid."
  fi
}


# Initialize Script
initialize

echo "Executing script: $0"

echo "Creating project: $PROJECT_ID"

if gcloud projects create "${PROJECT_ID}" \
  --organization="${ORGANIZATION_ID}" \
  --name="${PROJECT_NAME}" >/dev/null 2>&1; then
  echo "Successfully created project: $PROJECT_ID"
else
  err "Error: Failed to create project."
fi

echo "Setting active project to: $PROJECT_ID"

if gcloud config set project "$PROJECT_ID" >/dev/null 2>&1; then
  echo "Successfully set active project: $PROJECT_ID"
else
  err "Error: Failed to set the active project."
fi

echo "Linking billing account: $BILLING_ACCOUNT"

if gcloud beta billing projects link "$PROJECT_ID" \
  --billing-account "$BILLING_ACCOUNT" >/dev/null 2>&1; then
  echo "Successfully linked billing account: $BILLING_ACCOUNT"
else
  err "Error: Failed to link billing account."
fi

echo "Enabling Service APIs: $SERVICE_APIS"

for API in $APIS
do
  echo "Enabling API: $API"
  
  if gcloud services enable "$API" >/dev/null 2>&1; then
    echo "Successfully enabled API: $API"
  else
    err "Error: Failed to enable API."
  fi
done

echo "Service Accounts: $SERVICE_ACCOUNTS"
for SERVICE_ACCOUNT in $SERVICE_ACCOUNTS
do
  echo "Creating service accounts & keys: ${SERVICE_ACCOUNT}-${PROJECT_ID}.key"

  if gcloud iam service-accounts create "${SERVICE_ACCOUNT}" >/dev/null 2>&1; then
    echo "Successfully created service account: $SERVICE_ACCOUNT"
  else
    err "Error: Failed to create service account."
  fi
  
  # Give the service account enough time to be created
  sleep 5

  gcloud iam service-accounts keys create "${SERVICE_ACCOUNT}-${PROJECT_ID}.key" \
    --iam-account="${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"
done

ROLES="roles/artifactregistry.admin roles/cloudbuild.builds.editor roles/owner roles/run.admin roles/storage.admin roles/secretmanager.admin roles/iam.serviceAccountAdmin"
echo "Assigning User Role(s): Terraform User"
for ROLE in $ROLES
do
  if gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member=serviceAccount:terraform@"${PROJECT_ID}".iam.gserviceaccount.com \
    --role="${ROLE}" >/dev/null 2>&1; then
    echo "Successfully attached role: $ROLE"
  fi
done

echo "Project creation complete: $PROJECT_ID"
