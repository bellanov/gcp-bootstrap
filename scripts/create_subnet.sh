#!/bin/bash
#
# Create a Subnet.
#
#   Usage:
#     create_subnet.sh --name <SUBNET_NAME> --network <NETWORK_NAME> --ip-range <IP_RANGE> --region <REGION> --project <PROJECT_ID>
#     create_subnet.sh -n <SUBNET_NAME> -net <NETWORK_NAME> -ipr <IP_RANGE> -r <REGION> -p <PROJECT_ID>
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

  # Validate the Subnet argument
  if [ "$2" = "" ] ; then
    err "Error: SUBNET_NAME not provided or is invalid."
  fi

  # Initialize Verbosity
  if [ "$3" = "1" ] ; then
    debug="debug"
  else
    debug="warning"
  fi

  # Validate the Network Name argument
  if [ "$4" = "" ] ; then
    err "Error: NETWORK_NAME not provided or is invalid."
  fi

  # Validate the Network Name argument
  if [ "$5" = "" ] ; then
    err "Error: IP_RANGE not provided or is invalid."
  fi

  # Validate the Region argument
  if [ "$6" = "" ] ; then
    err "Error: REGION not provided or is invalid."
  fi

  # Display validated arguments / parameters
  echo "Project : $1"
  echo "Name    : $2"
  echo "Debug   : $debug"
  echo "Network : $4"
  echo "Range   : $5"
  echo "Region  : $6"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -n|--name) name="$2"; shift ;;
      -net|--network) network="$2"; shift ;;
      -ip|--ip-range) range="$2"; shift ;;
      -r|--region) region="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$name" "$debug" "$network" "$range" "$region"

echo "Executing script: $0"
echo "GCP project: $project"

# Set the project as the active
echo "Setting active project to: ${project}"

if gcloud config set project "${project}" >/dev/null 2>&1; then
  echo "Successfully set active project: ${project}"
else
  err "Error: Failed to set the active project: ${project}"
fi

# Create the Subnet
gcloud compute networks subnets create "${name}" \
    --range="${range}" --stack-type=IPV4_ONLY --network="${network}" \
    --region="${region}"
