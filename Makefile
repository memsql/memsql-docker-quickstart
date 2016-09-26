.PHONY: latest
latest:
	docker build -t memsql/quickstart:latest -f Dockerfile .
