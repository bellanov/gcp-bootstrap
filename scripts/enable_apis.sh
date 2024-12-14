#!/bin/bash
#
# Enable Service APIs in a GCP Project.
#
#   Usage:
#     enable_apis.sh <PROJECT_ID>
#

PROJECT_ID=$1
APIS="cloudresourcemanager.googleapis.com compute.googleapis.com dns.googleapis.com iam.googleapis.com"

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
echo "GCP project: $PROJECT_ID"

for API in $APIS
do
  echo "Enabling API: $API"
  if gcloud services enable "$API" --project "$PROJECT_ID" >/dev/null 2>&1; then
    echo "Successfully enabled API: $API"
  else
    err "Error: Failed to enable API."
  fi
done