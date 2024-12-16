#!/bin/bash
#
# Delete a Virtual Machine.
#
#   Usage:
#     delete_vm.sh --name <INSTANCE_NAME> --project <PROJECT_ID> --zone <ZONE.
#     delete_vm.sh -n <INSTANCE_NAME> -p <PROJECT_ID> -z <ZONE>
#

# TODO: Establish instance name dynamically using epoch
INSTANCE_NAME="instance-20241215-032445"

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
  echo "Usage: create_vm.sh --project <PROJECT_ID>"
  echo "Usage: create_vm.sh -p <PROJECT_ID>"
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
    err "Error: INSTANCE_NAME not provided or is invalid."
  fi

  # Validate the Zone argumeent
  if [ "$2" = "" ] ; then
    err "Error: ZONE not provided or is invalid."
  fi

  # Validate the Name argumeent
  if [ "$3" = "" ] ; then
    err "Error: INSTANCE_NAME not provided or is invalid."
  fi

  # Display validated arguments / parameters
  echo "Project : $project"
  echo "Zone    : $project"
  echo "Debug   : $debug"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -z|--zone) zone="$2"; shift ;;
      -n|--name) name="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$zone" "$name" "$debug"

echo "Executing script: $0"
echo "GCP project: $project"

# Create the Virtual Machines
gcloud compute instances delete "${name}" --project="${project}" \
  --zone="${zone}" --quiet
