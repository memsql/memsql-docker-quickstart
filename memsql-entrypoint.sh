#!/bin/bash
set -e

if [[ "$1" = "memsqld" ]]; then
    memsql-ops start
    memsql-ops memsql-start --all
    memsql-ops memsql-list

    # Check for a schema file at /schema.sql and load it
    if [[ -e /schema.sql ]]; then
        echo "Loading schema from /schema.sql"
        cat /schema.sql
        memsql < /schema.sql
    fi

    # Tail the logs to keep the container alive
    exec tail -F /memsql/master/tracelogs/memsql.log /memsql/leaf/tracelogs/memsql.log
else
    exec "$@"
fi
