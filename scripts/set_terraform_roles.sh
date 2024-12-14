#!/bin/bash
#
# Set the Terraform roles for a GCP Project.
#
#   Usage:
#     set_terraform_roles.sh <PROJECT_ID>
#

PROJECT_ID=$1

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
#   PROJECT_IDS
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

echo "Executing script: $0"
echo "Refreshing Terraform roles: $PROJECT_ID"

EXISTING_ROLES="roles/owner roles/run.admin roles/storage.admin roles/iam.serviceAccountAdmin"

echo "Removing Existing Role(s): Terraform User"
for ROLE in $EXISTING_ROLES
do
  echo "Removing existing role: ${ROLE}"

  if gcloud projects remove-iam-policy-binding "${PROJECT_ID}" \
  --member=serviceAccount:terraform@"${PROJECT_ID}".iam.gserviceaccount.com \
  --role="${ROLE}" >/dev/null 2>&1; then
    echo "Successfully removed role: ${ROLE}"
  else
    err "Error: Failed to remove the role. The role may already have been removed."
  fi
done

ASSIGN_ROLES="roles/owner roles/storage.admin roles/iam.serviceAccountAdmin"

echo "Assigning User Role(s): Terraform User"
for ROLE in $ASSIGN_ROLES
do
  echo "Assigning user role: ${ROLE}"

  if gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member=serviceAccount:terraform@"${PROJECT_ID}".iam.gserviceaccount.com \
  --role="${ROLE}" >/dev/null 2>&1; then
    echo "Successfully attached role: ${ROLE}"
  else
    err "Error: Failed to attach role."
  fi
done
