#!/bin/bash
#
# Create a GCP Project to isolate infrastructure.
#
#   Usage:
#     create_gcp_environment.sh --project <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing <BILLING_ACCOUNT_ID>
#     create_gcp_environment.sh -p <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>
#

# Load utility functions
# shellcheck disable=SC1091
source "$(dirname "$0")/util.sh"

# Globals:
#
#   TIMESTAMP - Unique timestamp to append to the project name
#   APIS - APIs to enable within the project

TIMESTAMP="$(date +%s)"

# Enabled APIs
# 
#   cloudresourcemanager.googleapis.com - Cloud Resource Manager
#   compute.googleapis.com - Compute Engine
#   dns.googleapis.com - Cloud DNS
#   firebase.googleapis.com - Firebase
#   iam.googleapis.com - Identity and Access Management

# APIs to enable
#
#   iam.googleapis.com - Identity and Access Management

APIS="cloudresourcemanager.googleapis.com iam.googleapis.com"

# Exit on error
set -e

#######################################
# Validate the arguments and initialize the script.
# Globals:
#   None.
# Arguments:
#   None.
  # Validate the GCP Project argument
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
  info "Project Name  : $1"
  info "Organization  : $2"
  info "Billing       : $4"
  info "Debug         : $debug"

}

#######################################
# Create a GCP Project.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes log message to stdout
#######################################
create_project() {
  # Establish Project Id
  project_id="${1}-${TIMESTAMP}"

  info "Creating project: ${project_id}"

  if gcloud projects create "${project_id}" \
    --organization="${2}" \
    --name="${1}" >/dev/null 2>&1; then
    info "Successfully created project: ${project_id}"
  else
    err "Error: Failed to create project: ${project_id}"
  fi

  # Set the project as the active
  info "Setting active project to: ${project_id}"

  if gcloud config set project "${project_id}" >/dev/null 2>&1; then
    info "Successfully set active project: ${project_id}"
  else
    err "Error: Failed to set the active project: ${project_id}"
  fi

  # Link the billing account to the project
  info "Linking billing account: ${3}"

  if gcloud beta billing projects link "${project_id}" \
    --billing-account "${billing}" >/dev/null 2>&1; then
    info "Successfully linked billing account: ${3}"
  else
    err "Error: Failed to link billing account: ${3}"
  fi

  # Enable the required services within the project
  echo "Enabling Service APIs: ${SERVICE_APIS}"

  for API in $APIS
  do
    echo "Enabling API: ${API}"

    if gcloud services enable "${API}" >/dev/null 2>&1; then
      echo "Successfully enabled API: ${API}"
    else
      err "Error: Failed to enable API."
    fi
  done

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

# Create the Project
create_project "$project" "$organization" "$billing"

# Project Creation Complete
info "Project creation complete: ${project}"
