.PHONY: latest
latest:
	docker build -t memsql/quickstart:minimal -f Dockerfile .
