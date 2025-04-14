#!/bin/bash

CRATEDB_HOST=$1
CRATEDB_USERNAME=$2
CRATEDB_PASSWORD=$3
TRIES=3
FILE_NAME="queries-tuned.sql"

export PGPASSWORD=$CRATEDB_PASSWORD

cat $FILE_NAME | while read -r query; do
    echo "$query";
    for i in $(seq 1 $TRIES); do
        psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t -c '\timing' -c "$query" | grep 'Time'
    done;
done;
