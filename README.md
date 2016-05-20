MemSQL Official Docker Image
============================

The official docker image for testing MemSQL + MemSQL Ops (cluster-in-a-box).

Check out the tutorial:
http://docs.memsql.com/latest/setup/docker/


## Pull image

```
docker pull memsql/quickstart
```

## Verify your machine satisfies our minimum requirements

```
docker run --rm --net=host memsql/quickstart check-system
```

## Spin up a MemSQL cluster on your machine

```
docker run -d -p 3306:3306 -p 9000:9000 --name=memsql memsql/quickstart
```

## Open the web interface

On Mac

```
open "http://$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' memsql):9000"
```

On Windows

```
start "http://$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' memsql):9000"
```

## Run a quick benchmark against MemSQL

```
docker run --rm -it --link=memsql:memsql memsql/quickstart simple-benchmark
```

## Open a MemSQL command line shell

```
docker run --rm -it --link=memsql:memsql memsql/quickstart memsql-shell
```

## Open a MemSQL command line shell directly on your Mac

```
mysql -u root -h $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' memsql)
```

## Stop and remove the container

```
docker stop memsql && docker rm -v memsql
```
