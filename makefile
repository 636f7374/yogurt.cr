YOGURT_OUT ?= bin/yogurt
YOGURT_SRC ?= cli.cr
SYSTEM_BIN ?= /usr/local/bin

install: build
	cp $(YOGURT_OUT) $(SYSTEM_BIN) && rm -f $(YOGURT_OUT)*
build: shard
	crystal build $(YOGURT_SRC) -o $(YOGURT_OUT) --release
test: shard
	crystal spec
shard:
	shards build
clean:
	rm -f $(YOGURT_OUT)* && rm -rf lib