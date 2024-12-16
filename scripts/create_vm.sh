#!/bin/bash
#
# Create a Virtual Machine.
#
#   Usage:
#     create_vm.sh --project <PROJECT_ID> --subnet <SUBNET>
#     create_vm.sh -p <PROJECT_ID> -s <SUBNET>
#

# Instance Configuration
TIMESTAMP="$(date +%s)"
INSTANCE_NAME="instance-${TIMESTAMP}"
MACHINE_TYPE="e2-micro"
PROVISIONING_MODEL="SPOT"

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

  # Validate the Zone argumeent
  if [ "$2" = "" ] ; then
    err "Error: ZONE not provided or is invalid."
  fi

  # Initialize Verbosity
  if [ "$3" = "1" ] ; then
    debug="debug"
  else
    debug="warning"
  fi

  # Validate the Subnet argumeent
  if [ "$4" = "" ] ; then
    err "Error: SUBNET not provided or is invalid."
  fi

  # Display validated arguments / parameters
  echo "Project : $1"
  echo "Zone    : $2"
  echo "Subnet  : $4"
  echo "Debug   : $debug"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--project) project="$2"; shift ;;
      -s|--subnet) subnet="$2"; shift ;;
      -z|--zone) zone="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$project" "$zone" "$debug" "$subnet"

echo "Executing script: $0"
echo "GCP project: $project"

# Create the Virtual Machines
gcloud compute instances create ${INSTANCE_NAME} --project="${project}" \
  --zone="${zone}" --machine-type=${MACHINE_TYPE} \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=subnet-1 \
  --no-restart-on-failure --maintenance-policy=TERMINATE \
  --provisioning-model=${PROVISIONING_MODEL} \
  --instance-termination-action=STOP \
  --service-account=terraform@"${project}".iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name="${INSTANCE_NAME}",image=projects/debian-cloud/global/images/debian-12-bookworm-v20241210,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --verbosity="${debug}"
