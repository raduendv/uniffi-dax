LIB_EXT := $(if $(filter Darwin,$(shell uname -s)),dylib,so)
DOTNET := $(HOME)/.dotnet/dotnet
MAVEN := $(HOME)/.sdkman/candidates/maven/current/bin/mvn
JAVA_HOME := $(HOME)/.sdkman/candidates/java/current
export JAVA_HOME

.PHONY: build
build: build-go build-dotnet build-js build-python build-java build-kotlin

.PHONY: build-cargo
build-cargo:
	cargo build

.PHONY: build-go
build-go: build-cargo
	cargo run --features bindgen-go --bin uniffi-bindgen-go -- target/debug/libuniffi_dax.$(LIB_EXT) --library --config uniffi.toml --out-dir target/go

# .net
.PHONY: build-dotnet
build-dotnet: build-cargo
	cargo run --features bindgen-cs --bin uniffi-bindgen-cs -- target/debug/libuniffi_dax.$(LIB_EXT) --library --config uniffi.toml --out-dir target/dotnet --no-format

.PHONY: build-js
build-js: build-cargo
	cargo run --features bindgen-js --bin uniffi-bindgen-js -- generate target/debug/libuniffi_dax.$(LIB_EXT) --crate-name uniffi-dax --manifest-path Cargo.toml --out-dir target/js
	cp target/debug/libuniffi_dax.$(LIB_EXT) target/js/

.PHONY: build-python
build-python: build-cargo
	cargo run --features bindgen-builtin --bin uniffi-bindgen-python -- generate target/debug/libuniffi_dax.$(LIB_EXT) --language python --config uniffi.toml --out-dir target/python

.PHONY: build-java
build-java: build-cargo
	cargo run --features bindgen-java --bin uniffi-bindgen-java -- generate target/debug/libuniffi_dax.$(LIB_EXT) --config uniffi.toml --out-dir target/java

.PHONY: build-kotlin
build-kotlin: build-cargo
	cargo run --features bindgen-builtin --bin uniffi-bindgen-kotlin -- generate target/debug/libuniffi_dax.$(LIB_EXT) --language kotlin --config uniffi.toml --out-dir target/kotlin --no-format

.PHONY: clean
clean:
	cargo clean

.PHONY: rsync
rsync:
	rsync -avz --delete \
		-e "ssh -o StrictHostKeyChecking=no -i ~/.ssh/radu-dax.pem" \
		--exclude target \
		--exclude node_modules \
		--exclude __pycache__ \
		--exclude examples/go/uniffi_dax \
		--exclude examples/dotnet/obj \
		--exclude examples/dotnet/bin \
		--exclude .git \
		. ec2-user@3.254.97.46:/home/ec2-user/uniffi-dax/

.PHONY: build-examples
build-examples: example-go example-dotnet example-js example-python example-java example-kotlin

.PHONY: example-go
example-go: build-go
	mkdir -p examples/go/uniffi_dax examples/go/bin
	cp -R target/go/uniffi_dax/. examples/go/uniffi_dax/
	cd examples/go && CGO_LDFLAGS="-L$(CURDIR)/target/debug -luniffi_dax" go build -o bin/uniffi-dax-example .

.PHONY: example-dotnet
example-dotnet: build-dotnet
	$(DOTNET) build examples/dotnet/UniffiDax.Example.csproj

.PHONY: example-js
example-js: build-js
	cd target/js && npm install
	node --check examples/js/main.mjs

.PHONY: example-python
example-python: build-python
	uv run --no-project python -m py_compile examples/python/main.py

.PHONY: example-java
example-java: build-java
	$(MAVEN) -q -f examples/java/pom.xml package

.PHONY: example-kotlin
example-kotlin: build-kotlin
	$(MAVEN) -q -f examples/kotlin/pom.xml package

.PHONY: run-examples
run-examples: run-example-go run-example-dotnet run-example-js run-example-python run-example-java run-example-kotlin

.PHONY: run-example-go
run-example-go: example-go
	LD_LIBRARY_PATH="$(CURDIR)/target/debug:$${LD_LIBRARY_PATH:-}" DYLD_LIBRARY_PATH="$(CURDIR)/target/debug:$${DYLD_LIBRARY_PATH:-}" examples/go/bin/uniffi-dax-example

.PHONY: run-example-dotnet
run-example-dotnet: example-dotnet
	$(DOTNET) run --project examples/dotnet/UniffiDax.Example.csproj --no-build

.PHONY: run-example-js
run-example-js: example-js
	node examples/js/main.mjs

.PHONY: run-example-python
run-example-python: example-python
	cp target/debug/libuniffi_dax.$(LIB_EXT) target/python/
	PYTHONPATH="$(CURDIR)/target/python" uv run --no-project python examples/python/main.py

.PHONY: run-example-java
run-example-java: example-java
	$(MAVEN) -q -f examples/java/pom.xml -Djna.library.path=$(CURDIR)/target/debug exec:java

.PHONY: run-example-kotlin
run-example-kotlin: example-kotlin
	$(MAVEN) -q -f examples/kotlin/pom.xml -Djna.library.path=$(CURDIR)/target/debug exec:java

.PHONY: remote-deps
remote-deps: rsync
	ssh -o StrictHostKeyChecking=no -i ~/.ssh/radu-dax.pem ec2-user@3.254.97.46 'cd /home/ec2-user/uniffi-dax && bash setup-al2023.sh'

.PHONY: remote-build
remote-build: rsync
	ssh -o StrictHostKeyChecking=no -i ~/.ssh/radu-dax.pem ec2-user@3.254.97.46 'cd /home/ec2-user/uniffi-dax && bash remote-build.sh'