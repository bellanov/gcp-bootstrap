#!/bin/bash
#
# Delete a GCP Project and disable its billing.
#
#   Usage:
#     delete_gcp_environment.sh <PROJECT_ID> <PROJECT_ID> <N>
#

# Load utility functions
# shellcheck disable=SC1091
source "$(dirname "$0")/util.sh"

PROJECT_IDS="$*"

# Exit on error
set -e

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
  info "Deleting project: $PROJECT"

  if gcloud projects delete "$PROJECT" --quiet >/dev/null 2>&1; then
    info "Successfully deleted project: $PROJECT"
  else
    err "Error: Failed to delete project. The specified project may not exist."
  fi

  info "Unlinking project billing: $PROJECT"

  if gcloud beta billing projects unlink "$PROJECT" >/dev/null 2>&1; then
    info "Successfully unlinked project billing: $PROJECT"
  else
    err "Error: Failed to unlink project billing."
  fi
done
