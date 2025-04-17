#!/bin/bash

TRIES=3
FILE_NAME="queries-tuned.sql"

cat $FILE_NAME | while read -r query; do
    echo "$query";
    for i in $(seq 1 $TRIES); do
        psql -U $CRATEDB_USERNAME -h $CRATEDB_HOST -t -c '\timing' -c "$query" | grep 'Time'
    done;
done;
