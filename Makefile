.PHONY: test lint

all: lint test build

test:
	bats --recursive test/

lint:
	find test/ -name "*.bats" -exec shellcheck {} \;
	yamllint test/

build:
	./build.sh
