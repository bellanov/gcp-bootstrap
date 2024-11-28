#!/bin/bash
#
# Delete a GCP Project and disable its billing.

for PROJECT in "$@"
do
  echo "Deleting project: $PROJECT"
  gcloud projects delete "$PROJECT" --quiet
  gcloud beta billing projects unlink "$PROJECT"
done
