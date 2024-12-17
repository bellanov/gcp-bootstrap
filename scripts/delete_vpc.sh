#!/bin/bash
#
# Delete a VPC.
#
#   Usage:
#     delete_vpc.sh --name <VPC_NAME> --rules <FIREWALL_RULES> --project <PROJECT_ID>
#     delete_vpc.sh -n <VPC_NAME> -r <FIREWALL_RULES> -p <PROJECT_ID>
#

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
    err "Error: PROJECT_ID not provided or is invalid."
  fi

  # Validate the VPC Name argument
  if [ "$2" = "" ] ; then
    err "Error: VPC_NAME not provided or is invalid."
  fi

  # Validate the Firewall Rules argument
  if [ "$3" = "" ] ; then
    err "Error: FIREWALL_RULES not provided or is invalid."
  fi

  # Display validated arguments / parameters
  echo "Project         : $1"
  echo "VPC             : $2"
  echo "Firewall Rules  : $3"
  echo "Debug           : $4"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -n|--name) name="$2"; shift ;;
      -r|--rules) rules="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$name" "$rules" "$debug"

echo "Executing script: $0"
echo "GCP project: $project"

# Delete the Firewall Rules
for rule in $rules
do
  echo "Deleting firewall rule: ${rule}"
  if gcloud compute firewall-rules delete "${name}-${rule}" --project="${project}" \
    --quiet >/dev/null 2>&1; then
    echo "Successfully deleted firewall rule: ${name}-${rule}"
  else
    err "Error: Failed to delete firewall rule: ${name}-${rule}"
  fi
done

# Delete the VPC
gcloud compute networks delete "${name}" --project="${project}" --quiet
