To build run the following command:

    docker build -t memsql/quickstart .

To publish, do the above to override the latest tag, and then tag the Ops
version as well.

    docker tag memsql/quickstart:latest memsql/quickstart:MEMSQL_OPS_VERSION

Then push

    docker push memsql/quickstart
    docker push memsql/quickstart:MEMSQL_OPS_VERSION
