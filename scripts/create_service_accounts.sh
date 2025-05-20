#!/bin/bash
#
# Create Terraform User.
#
#   Usage:
#     create_service_account_keys.sh --project <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing <BILLING_ACCOUNT_ID>
#     create_service_account_keys.sh -p <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>
#

# Load utility functions
# shellcheck disable=SC1091
source "$(dirname "$0")/util.sh"

# Load utility functions
# shellcheck disable=SC1091
source "$(dirname "$0")/util.sh"

# Globals:
#
#
#   SERVICE_ACCOUNTS - Service accounts to create within the project

SERVICE_ACCOUNTS="terraform"

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

  # Set the project as the active
  info "Setting active project to: ${1}"

  if gcloud config set project "${1}" >/dev/null 2>&1; then
    info "Successfully set active project: ${1}"
  else
    err "Error: Failed to set the active project: ${1}"
  fi

}

#######################################
# Create Service Accounts.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes log message to stdout
#######################################
create_service_accounts() {

  # Create the Service Accounts
  info "Service Accounts: ${SERVICE_ACCOUNTS}"
  for SERVICE_ACCOUNT in $SERVICE_ACCOUNTS
  do
    info "Creating service accounts: ${SERVICE_ACCOUNT}-${1}.key"

    if gcloud iam service-accounts list --filter="email=${SERVICE_ACCOUNT}@${1}.iam.gserviceaccount.com" --format="value(email)" | grep -q "${SERVICE_ACCOUNT}@${project_id}.iam.gserviceaccount.com"; then
      info "Service account already exists: ${SERVICE_ACCOUNT}"
    else
      if gcloud iam service-accounts create "${SERVICE_ACCOUNT}"; then
        info "Successfully created service account: ${SERVICE_ACCOUNT}"
      else
        err "Error: Failed to create service account: ${SERVICE_ACCOUNT}. It may already exist."
      fi
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

# Intialize Script
initialize "$project" "$organization" "$debug" "$billing"

# Create the Service Accounts
create_service_accounts "$project"
