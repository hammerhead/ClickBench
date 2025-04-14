#!/bin/bash

command -v psql || exit 1

# Variables CRATEDB_USERNAME, CRATEDB_HOST, PGPASSWORD have been exported by setup.sh

echo "Waiting for the cluster to be available"
while true
do
  psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t -c "SELECT 1" && break
  sleep 1
done

echo "Creating the table"
psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t < "create.sql"

echo "Importing data"
psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t -c '\timing' -c "
  COPY hits
  FROM 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
  WITH
  (
    "delimiter"=e'\t',
    "format"='csv',
    "header"=false,
    "empty_string_as_null"=TRUE
  )
  RETURN SUMMARY;"

# One record did not load:
# 99997496
# {"Missing closing quote for value\n at [Source: UNKNOWN; line: 1, column: 1069]":{"count":1,"line_numbers":[93557187]}}
# Time: 10687056.069 ms (02:58:07.056)
echo "Refreshing table"
psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t -c "REFRESH TABLE hits; OPTIMIZE TABLE hits;"

# Some queries don't fit into the available heap space and raise an CircuitBreakingException
echo "Starting queries"
./run.sh 2>&1 | tee log.txt

# Look up shard sizes from system tables. Only consider primary shards in case of multi-node setups with replication.
echo "Calculating shard size"
psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t -c "SELECT SUM(size) FROM sys.shards WHERE table_name = 'hits' AND primary = TRUE;"

grep -oP 'Time: \d+\.\d+ ms|ERROR' < log.txt | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
  awk '{ if ($1 == "ERROR") { skip = 1 } else { if (i % 3 == 0) { printf "[" }; printf skip ? "null" : ($1 / 1000); if (i % 3 != 2) { printf "," } else { print "]," }; ++i; skip = 0; } }'

# Delete the cluster
croud clusters list --output json | jq '.[] | select(.fqdn == "clickbench.eks1.eu-west-1.aws.cratedb.net.").id'