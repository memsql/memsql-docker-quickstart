MemSQL Official (Minimal) Docker Image
======================================

This is a Docker image that spins up very fast and is suited to testing or
playing around with MemSQL. This image includes our Developer license which is
not to be used in a production environment.  If you want to evaluate MemSQL for
a production environment you can download our Enterprise Trial here:
https://www.memsql.com/download/

```bash
# Download the latest version of the minimal image
docker pull memsql/quickstart:minimal

# Run the minimal image
docker run -d --name memsql -p3306:3306 memsql/quickstart:minimal

# Mount the data somewhere if you want to keep it around after killing the container
docker run -d --name memsql -v /host/path/to/state:/state memsql/quickstart:minimal
```

You can also build the Docker image locally after checking out this branch:

```
# Make the image locally
make
```
