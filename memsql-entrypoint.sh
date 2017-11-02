#!/usr/bin/dumb-init /bin/bash
set -e

function silent_query {
    mysql -u root -h 127.0.0.1 -P "${1}" -e "${2}" >/dev/null 2>&1
}

# Make sure state directory is setup
mkdir -p \
    /state/master/tracelogs /state/master/data /state/master/plancache \
    /state/leaf/tracelogs /state/leaf/data /state/leaf/plancache
chown memsql:memsql \
    /state/master/tracelogs /state/master/data /state/master/plancache \
    /state/leaf/tracelogs /state/leaf/data /state/leaf/plancache

# Make sure the internal table cache is setup
rsync -a /cache/master/ /state/master/plancache
rsync -a /cache/leaf/ /state/leaf/plancache

if [[ "$1" = "memsqld" ]]; then
    # Start cluster
    /master/memsqld -u memsql >/state/master/stdout 2>/state/master/stderr &
    /leaf/memsqld -u memsql >/state/leaf/stdout 2>/state/leaf/stderr &

    echo "Waiting for cluster to start..."
    while true; do
        if silent_query 3306 "SELECT 1" && silent_query 3307 "SELECT 1"; then
            break
        fi
        sleep 0.1
    done
    echo "Cluster started."

    # Configure cluster if needed
    if ! silent_query 3306 "SHOW AGGREGATORS" ; then
        silent_query 3306 "BOOTSTRAP AGGREGATOR '127.0.0.1'"
        silent_query 3306 "ADD LEAF root@'127.0.0.1':3307"
    fi

    # Check for a schema file at /schema.sql and load it
    if [[ -e /schema.sql ]]; then
        echo "Loading schema from /schema.sql"
        mysql -u root -h 127.0.0.1 </schema.sql
    fi

    echo "Ready for connections, tailing master log."

    # Tail the logs to keep the container alive
    tail -F /state/master/tracelogs/memsql.log
else
    "$@"
fi
