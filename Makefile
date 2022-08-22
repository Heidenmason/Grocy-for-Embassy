ASSETS := $(shell yq e '.assets.[].src' manifest.yaml)
ASSET_PATHS := $(addprefix assets/,$(ASSETS))
VERSION := $(shell yq e ".version" manifest.yaml)
#HELLO_WORLD_SRC := $(shell find ./grocy/src) grocy/Cargo.toml grocy/Cargo.lock
S9PK_PATH=$(shell find . -name grocy.s9pk -print)

# delete the target of a rule if it has changed and its recipe exits with a nonzero exit status
.DELETE_ON_ERROR:

all: verify

verify: grocy.s9pk $(S9PK_PATH)
	embassy-sdk verify s9pk $(S9PK_PATH)

clean:
	rm -f image.tar
	rm -f grocy.s9pk

grocy.s9pk: manifest.yaml image.tar instructions.md #$(ASSET_PATHS)
	embassy-sdk pack

image.tar: Dockerfile docker_entrypoint.sh check-web.sh #grocy/target/aarch64-unknown-linux-musl/release/grocy
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/grocy/main:$(VERSION) --platform=linux/arm64 -o type=docker,dest=image.tar .

grocy/target/aarch64-unknown-linux-musl/release/grocy: $(GROCY_SRC)
	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/grocy:/home/rust/src start9/rust-musl-cross:aarch64-musl cargo build --release
