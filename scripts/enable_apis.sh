#!/bin/bash
#
# Enable Service APIs in a GCP Project.

PROJECT_ID=$1
PROJECTS="alexei-1684209060 bellanov-1682390142 fantasyace-1682390017 puter-1684209240 quantcloud-1684208465"
APIS="artifactregistry.googleapis.com cloudbuild.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com domains.googleapis.com dns.googleapis.com iam.googleapis.com run.googleapis.com secretmanager.googleapis.com"

echo "Executing script: $0"
echo "GCP project: $PROJECT_ID"

for API in $APIS
do
    echo "Enabling API: $API"
    gcloud services enable $API --project $PROJECT_ID
done