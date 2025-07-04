#!/bin/bash
#
# List the contents of a GCP bucket.
#
#   Usage:
#    list_bucket_contents.sh <bucket_name>
#

BUCKET_NAME="$1"

gsutil ls -r "gs://${BUCKET_NAME}/**"
