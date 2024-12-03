#!/bin/bash
#
# Delete a GCP Project and disable its billing.
#
#   Usage:
#       delete_gcp_environment.sh <PROJECT_ID> <PROJECT_ID> <N>
#


PROJECT_IDS="$*"

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
  if [ "${PROJECT_IDS}" = "" ] ; then
    err "Error: Arguments not provided or are invalid."
  fi
}


# Initialize Script
initialize

for PROJECT in "$@"
do
  echo "Deleting project: $PROJECT"

  if gcloud projects delete "$PROJECT" --quiet >/dev/null 2>&1; then
    echo "Successfully deleted project: $PROJECT"
  else
    err "Error: Failed to delete project. The specified project may not exist."
  fi

  echo "Unlinking project billing: $PROJECT"

  if gcloud beta billing projects unlink "$PROJECT" >/dev/null 2>&1; then
    echo "Successfully unlinked project billing: $PROJECT"
  else
    err "Error: Failed to unlink project billing."
  fi
done
