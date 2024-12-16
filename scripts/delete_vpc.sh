#!/bin/bash
#
# Delete a VPC.
#
#   Usage:
#     delete_vpc.sh --name <VPC_NAME> --project <PROJECT_ID> --subnets <SUBNETS> --region <REGION>
#     delete_vpc.sh -n <VPC_NAME> -p <PROJECT_ID> -s <SUBNETS> -r <REGION>
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

  # Validate the Subnets argument
  if [ "$3" = "" ] ; then
    err "Error: SUBNETS not provided or is invalid."
  fi

  # Validate the Region argument
  if [ "$4" = "" ] ; then
    err "Error: REGION not provided or is invalid."
  fi

  # Validate the Firewall Rules argument
  if [ "$5" = "" ] ; then
    err "Error: FIREWALL_RULES not provided or is invalid."
  fi

  # Display validated arguments / parameters
  echo "GCP Project     : $1"
  echo "VPC Name        : $2"
  echo "Subnets         : $3"
  echo "Firewall Rules  : $4"
  echo "Region          : $5"
  echo "Debug           : $6"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -n|--name) name="$2"; shift ;;
      -s|--subnets) subnets="$2"; shift ;;
      -r|--region) region="$2"; shift ;;
      -fwr|--firewall-rules) rules="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$name" "$subnets" "$region" "$rules" "$debug"

echo "Executing script: $0"
echo "GCP project: $project"

# Delete the Subnets
for subnet in $subnets
do
  echo "Deleting subnet: ${subnet}"
  if gcloud compute networks subnets delete "${subnet}" \
  --project="${project}" --region="${region}" --quiet >/dev/null 2>&1; then
    echo "Successfully deleted subnet: ${subnet}"
  else
    err "Error: Failed to delete subnet: ${subnet}"
  fi
done

# Delete the Firewall Rules
for rule in $rules
do
  echo "Deleting firewall rule: ${rule}"
  if gcloud compute firewall-rules delete "${rule}" --project="${project}" \
    --quiet >/dev/null 2>&1; then
    echo "Successfully deleted firewall rule: ${rule}"
  else
    err "Error: Failed to delete firewall rule: ${rule}"
  fi
done

# Delete the VPC
gcloud compute networks delete "${name}" --project="${project}" --quiet
