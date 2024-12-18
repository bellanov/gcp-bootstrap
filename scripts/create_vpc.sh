#!/bin/bash
#
# Create a VPC.
#
#   Usage:
#     create_vpc.sh --name <VPC_NAME> --project <PROJECT_ID>
#     create_vpc.sh -n <VPC_NAME> -p <PROJECT_ID>
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

  # Display validated arguments / parameters
  echo "Project : $project"
  echo "VPC     : $name"
  echo "Debug   : $debug"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -n|--name) name="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$name" "$debug"

echo "Executing script: $0"
echo "Project: $project"

# Set the project as the active
echo "Setting active project to: ${project}"

if gcloud config set project "${project}" >/dev/null 2>&1; then
  echo "Successfully set active project: ${project}"
else
  err "Error: Failed to set the active project."
fi

# Create the VPC network
gcloud beta compute networks create "${name}" \
    --description=Cloud\ Academy\ Labs. --subnet-mode=custom --mtu=1460 \
    --bgp-routing-mode=regional --bgp-best-path-selection-mode=legacy

# Create the firewall rules
gcloud compute firewall-rules create "${name}"-allow-icmp \
    --network=projects/"${project}"/global/networks/"${name}" \
    --description=Allows\ ICMP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network. \
    --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=icmp

gcloud compute firewall-rules create "${name}"-allow-ssh \
  --direction=INGRESS --priority=1000 --network="${name}" --action=ALLOW --rules=tcp:22 \
  --source-ranges=0.0.0.0/0
