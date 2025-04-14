#!/bin/bash

SUBSCRIPTION_ID=$1
ORGANIZATION_ID=$2
REGION="eks1.eu-west-1.aws"

CRATEDB_USERNAME="admin"
# Not a strong password in any way, but should be good enough for our purposes
CRATEDB_PASSWORD=$(date +%s | sha256sum | base64 | head -c 24)
CRATEDB_CLUSTERNAME="clickbench"
CRATEDB_VERSION="5.10.4"

if [ $# != 2 ]; then
  echo "Missing parameters. Usage: ./setup.sh <SUBSCRIPTION ID> <ORGANIZATION ID>"
  exit 1
fi

# See https://cratedb.com/docs/cloud/cli/en/latest/getting-started.html for how to install
command -v croud || exit 1

croud clusters deploy \
    --product-name CR1 \
    --tier default \
    --username admin \
    --region $REGION \
    --password "$CRATEDB_PASSWORD" \
    --subscription-id "$SUBSCRIPTION_ID" \
    --disk-size-gb 512 \
    --org-id "$ORGANIZATION_ID" \
    --cluster-name $CRATEDB_CLUSTERNAME \
    --version $CRATEDB_VERSION

# Make connection details available to benchmark.sh so they don't need to be
# passed on the command line again
export PGPASSWORD=$CRATEDB_PASSWORD
export CRATEDB_HOST="${CRATEDB_CLUSTERNAME}.${REGION}.cratedb.net"
export CRATEDB_USERNAME=$CRATEDB_USERNAME
