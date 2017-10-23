#!/bin/bash
set -e

if [[ "$1" = "memsqld" ]]; then
    memsql-ops start
    
    #Eliminate Minimum Core Count Requirement
    memsql-ops memsql-update-config --all --key minimum_core_count --value 0	
    
    if [[ "$IGNORE_MIN_REQUIREMENTS" = "1" ]]; then
        memsql-ops memsql-update-config --all --key minimum_memory_mb --value 0
    fi

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
