.PHONY: builder
builder:
	docker build -t memsql/quickstart:builder .

.PHONY: push-builder
push-builder:
	docker push memsql/quickstart:builder

.PHONY: latest
latest:
	docker build -t memsql/quickstart:latest -f Dockerfile.latest .
