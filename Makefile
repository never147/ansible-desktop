.PHONY: all
all: bootstrap apply

apply:
	./bin/apply.sh

bootstrap:
	./bin/bootstrap.sh

