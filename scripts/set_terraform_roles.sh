#!/bin/bash
#
# Set the Terraform roles for a GCP Project.

PROJECT_ID=$1

echo "Executing script: $0"
echo "Refreshing Terraform roles: $PROJECT_ID"

EXISTING_ROLES="roles/artifactregistry.admin roles/cloudbuild.builds.editor roles/owner roles/run.admin roles/storage.admin roles/secretmanager.admin roles/iam.serviceAccountAdmin"

echo "Removing Existing Role(s): Terraform User"
for ROLE in $EXISTING_ROLES
do
    gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=${ROLE}
done

ASSIGN_ROLES="roles/artifactregistry.admin roles/cloudbuild.builds.editor roles/owner roles/run.admin roles/storage.admin roles/secretmanager.admin roles/iam.serviceAccountAdmin"

echo "Assigning User Role(s): Terraform User"
for ROLE in $ASSIGN_ROLES
do
    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=${ROLE}
done
