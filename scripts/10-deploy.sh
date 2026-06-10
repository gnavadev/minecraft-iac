#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform"

terraform init
terraform validate
terraform apply -auto-approve

echo "Deployed. The first start takes 2-4 minutes (image pull + world generation)."
echo "Run scripts/20-get-server-ip.sh to get the address."
