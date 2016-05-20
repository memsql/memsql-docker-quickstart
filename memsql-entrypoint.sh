#!/bin/bash
set -e

if [ "$1" = "memsqld" ]; then
    # Start up the cluster
    memsql-ops start
    memsql-ops memsql-start --all
    memsql-ops memsql-list

    # Tail the logs to keep the container alive
    exec tail -F /memsql/master/tracelogs/memsql.log
fi

exec "$@"

