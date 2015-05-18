## Build image

```
docker build -t memsql/quickstart .
```

## Spin up a MemSQL cluster on your machine

```
docker pull memsql/quickstart
docker run -d -p 3306:3306 -p 9000:9000 --name="memsql" memsql/quickstart
```

## Open the web interface

```
open "http://$(boot2docker ip):9000"
```

## Open a MemSQL command line shell

```
docker run --rm -it --link=memsql:memsql memsql/quickstart memsql-shell
```

## Stop and remove the container

```
docker stop memsql && docker rm -v memsql
```
