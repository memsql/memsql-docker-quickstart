MemSQL Official Docker Image
============================

The official docker image for testing MemSQL + MemSQL Ops (cluster-in-a-box).

Check out the tutorial:
http://docs.memsql.com/docs/quick-start-with-docker/

### Example usage

```
# Pull the image
docker pull memsql/quickstart


# Verify your machine satisfies our minimum requirements
docker run --rm memsql/quickstart check-system


# Spin up a MemSQL cluster on your machine
docker run -d -p 3306:3306 -p 9000:9000 --name=memsql memsql/quickstart


# Wait until the cluster is ready before connecting to it.
sleep 10

# Run a quick benchmark against MemSQL
docker run --rm -it --link=memsql:memsql memsql/quickstart simple-benchmark


# Open a MemSQL command line shell
docker run --rm -it --link=memsql:memsql memsql/quickstart memsql-shell


# Stop and remove the container
docker rm -fv memsql
```

### Persistent data (using Docker volumes)

The image is setup to write all data for the MemSQL nodes into the `/memsql`
directory inside the container.  This makes it easy to mount all of the
persistent data into a Docker volume.  For example, the following command will
start a new MemSQL quickstart container and save the data into a Docker named
volume called `memsql`.

```
docker run -d -p 3306:3306 -p 9000:9000 -v memsql:/memsql --name=memsql memsql/quickstart
```

If you want to mount any directory on the host machine - the directory first
needs to be initialized.  You can do this like so:

```
mkdir /host/data
docker run --rm -v $(pwd)/data:/template memsql/quickstart /bin/bash -c 'cp -r /memsql/* /template && chown -R 1000:1000 /template'
```

And then you can mount it into the quickstart container over `/memsql`:

```
docker run -d -p 3306:3306 -p 9000:9000 -v /host/data:/memsql --name=memsql memsql/quickstart
```

### Custom schema file at start

If you mount a SQL file to /schema.sql inside the container it will be loaded
when the cluster is started. Example:

```
echo "CREATE DATABASE test;" > schema.sql
docker run -d -v $(PWD)/schema.sql:/schema.sql -p 3306:3306 -p 9000:9000 --name=memsql memsql/quickstart
```
