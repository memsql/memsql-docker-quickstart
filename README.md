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


# Run a quick benchmark against MemSQL
docker run --rm -it --link=memsql:memsql memsql/quickstart simple-benchmark


# Open a MemSQL command line shell
docker run --rm -it --link=memsql:memsql memsql/quickstart memsql-shell


# Stop and remove the container
docker rm -fv memsql
```

### Recommended system settings

It is recommended to run MemSQL and MemSQL Ops with a couple of specific system settings.  The full set of settings are documented here: https://docs.memsql.com/tutorials/v5.8/installation-best-practices/

One option is to set the settings when you run the container.  For example you can do something like this to setup the recommended sysctl settings:

```
docker run -d --sysctl net.core.somaxconn=1024 --sysctl vm.min_free_kbytes=2639550 -p 3306:3306 -p 9000:9000 -v memsql:/memsql --name=memsql memsql/quickstart  
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

### Ignore system requirements check

MemSQL is designed to run on machines with minimum systems requirements. Please read
[this article](https://help.memsql.com/hc/en-us/articles/115001215583-My-hosts-have-less-than-minimum-MemSQL-system-requirements-How-can-I-make-MemSQL-run-on-those-hosts-) 
to understand how disabling this check could lead to a less ideal experience. If you
understand the risk you may disable the check by passing in a `IGNORE_MIN_REQUIREMENTS=1`
Docker environment variable:

```
docker run -d -p 3306:3306 -p 9000:9000 --name=memsql -e IGNORE_MIN_REQUIREMENTS=1 memsql/quickstart
```
