ZIG_LIBS := add.zig
RUST_LIBS := sub.rs
ZIG_WASM := $(ZIG_LIBS:%.zig=build/%.wasm)
RUST_WASM := $(RUST_LIBS:%.rs=build/%.wasm)
WASM_LIBS := $(ZIG_WASM) $(RUST_WASM)

WASM_OUT := $(wildcard build/*.wasm)
WATS := $(WASM_OUT:%.wasm=%.wat)

all: $(WASM_LIBS) build-harness
	node build/run.js
.PHONY: all

run-all: $(WASM_LIBS)
	$(foreach wasmf,$(WASM_OUT),wasm-interp $(wasmf) --run-all-exports;)
.PHONY: run-all

# JavaScript

build-harness: build/run.js
.PHONY: build-harness

build/%.js: %.js
	@cp $< $@

# Wasm Text (for debugging)

text-all: $(WATS)
	@echo $<
.PHONY: text-all

%.wat: %.wasm
	wasm2wat $< -o $@

# Zig

$(ZIG_WASM): build/%.wasm: %.zig | mkdirs
	zig build-lib $< --name $(subst .wasm,,$@) -target wasm32-freestanding

# Rust

$(RUST_WASM): build/%.wasm: %.rs | mkdirs
	rustc $< -o $@ --crate-type cdylib --target wasm32-unknown-unknown

# Meta

mkdirs:
	@mkdir -p build
.PHONY: mkdirs

clean:
	rm -rf build
.PHONY: clean
