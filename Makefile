.PHONY: latest
latest: builder
	docker build -t memsql/quickstart:latest -f Dockerfile.latest .

.PHONY: builder
builder:
	docker build -t memsql/quickstart:builder .

.PHONY: push-builder
push-builder:
	docker push memsql/quickstart:builder
