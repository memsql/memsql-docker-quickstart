MemSQL Official (Minimal) Docker Image
======================================

This is a beta image that spins up very fast and is more suited to testing or
playing around with MemSQL.  Check out our Master branch for the official image
that has more features.

```bash
# Build the minimal image
make

# Run the minimal image
docker run -d --name memsql -p3306:3306 memsql/quickstart:minimal

# Mount the data somewhere if you want to keep it around after killing the container
docker run -d --name memsql -v /host/path/to/state:/state memsql/quickstart:minimal
```
