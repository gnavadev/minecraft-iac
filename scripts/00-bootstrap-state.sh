#!/usr/bin/env bash
set -euo pipefail

BUCKET_NAME="${1:?Usage: ./00-bootstrap-state.sh <unique-bucket-name>}"
REGION="us-east-1"

aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}"

aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo "State bucket '${BUCKET_NAME}' created. Put this name in terraform/backend.tf"
