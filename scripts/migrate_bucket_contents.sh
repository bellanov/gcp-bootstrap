#!/bin/bash
#
# Migrate contents of a GCP bucket to a new prefix.
#
#   Usage:
#     migrate_bucket_contents.sh <bucket_name> <source_prefix> <destination_prefix>
#

BUCKET_NAME="$1"
SOURCE_PREFIX="$2"
DESTINATION_PREFIX="$3"

gsutil mv "gs://${BUCKET_NAME}/${SOURCE_PREFIX}/**" "gs://${SOURCE_PREFIX}/${DESTINATION_PREFIX}/"
