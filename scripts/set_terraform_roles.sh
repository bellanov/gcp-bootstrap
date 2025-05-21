#!/bin/bash
#
# Set the Terraform roles for a GCP Project.
#
#   Usage:
#     set_terraform_roles.sh <PROJECT_ID>
#

# Load utility functions
# shellcheck disable=SC1091
source "$(dirname "$0")/util.sh"

# Globals:
#
#   PROJECT_ID - GCP Project ID
#   APIS - APIs to enable within the project
#   SERVICE_ACCOUNTS - Service accounts to create within the project


# GCP Project ID
PROJECT_ID=$1

# Existing roles to remove
EXISTING_ROLES="roles/artifactregistry.admin roles/owner roles/storage.admin roles/iam.serviceAccountAdmin"

# Roles to assign
ASSIGN_ROLES="roles/owner roles/storage.admin roles/iam.serviceAccountAdmin"

# Exit on error
set -e

#######################################
# Validate the arguments and initialize the script.
# Globals:
#   PROJECT_ID
# Arguments:
#   None.
#######################################
initialize() {
  # Detect the presence of all arguments, otherwise exit
  if [ "${PROJECT_ID}" = "" ] ; then
    err "Error: Arguments not provided or are invalid."
  fi
}


# Initialize Script
initialize

info "Refreshing Terraform roles: $PROJECT_ID"


# Remove Existing Roles
info "Removing Existing Role(s): Terraform User"

for ROLE in $EXISTING_ROLES
do
  info "Removing existing role: ${ROLE}"

  if gcloud projects remove-iam-policy-binding "${PROJECT_ID}" \
  --member=serviceAccount:terraform@"${PROJECT_ID}".iam.gserviceaccount.com \
  --role="${ROLE}" >/dev/null 2>&1; then
    info "Successfully removed role: ${ROLE}"
  else
    info "Warning: Failed to remove the role. The role may already have been removed."
  fi
done

# Assign Updated Roles
info "Assigning User Role(s): Terraform User"
for ROLE in $ASSIGN_ROLES
do
  info "Assigning user role: ${ROLE}"

  if gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member=serviceAccount:terraform@"${PROJECT_ID}".iam.gserviceaccount.com \
  --role="${ROLE}" >/dev/null 2>&1; then
    info "Successfully attached role: ${ROLE}"
  else
    err "Error: Failed to attach role."
  fi
done

info "Terraform roles have been set for project: $PROJECT_ID"
