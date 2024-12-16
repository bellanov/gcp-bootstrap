#!/bin/bash
#
# Create a Virtual Machine.
#
#   Usage:
#     create_vm.sh --project <PROJECT_ID>
#     create_vm.sh -p <PROJECT_ID>
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
    err "Error: PROJECT_ID not provided or is invalid."
  fi

  # Display validated arguments / parameters
  echo "GCP Project  : $project"
  echo "Debug        : $debug"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$debug"

# TODO: Establish instance name dynamically using epoch
instance_name="instance-20241215-032445"

echo "Executing script: $0"
echo "GCP project: $project"

# Create the Virtual Machine
gcloud compute instances create ${instance_name} --project="${project}" \
  --zone=us-central1-c --machine-type=e2-micro \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=subnet-1 \
  --no-restart-on-failure --maintenance-policy=TERMINATE --provisioning-model=SPOT \
  --instance-termination-action=STOP \
  --service-account=terraform@"${project}".iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name=instance-20241215-032445,image=projects/debian-cloud/global/images/debian-12-bookworm-v20241210,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
