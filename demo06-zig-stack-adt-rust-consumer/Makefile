ZIG_SRC := src_zig/lib.zig
WAT_SRC := $(wildcard src/*.wat)

ZIG_WASM := $(ZIG_SRC:src_zig/%.zig=build/lib-zig/%.wasm)
ZIG_WASM_EXPORT := $(ZIG_WASM:build/lib-zig/%.wasm=build/lib-zig-exported/%.wasm)
WAT_WASM := $(WAT_SRC:src/%.wat=build/%.wasm)
RUST_WASM := build/lib-rust/lib.wasm

WASM_LIBS := $(ZIG_WASM_EXPORT) $(WAT_WASM) $(RUST_WASM)

WASM_ALL := $(shell find build -name '*.wasm')
WAT_ALL := $(patsubst %.wasm,%.wat,$(WASM_ALL))
DCM_ALL := $(patsubst %.wasm,%.dcm,$(WASM_ALL))

WAT2WASM := wat2wasm
WASM2WAT = wasm2wat
WASM_DCM = wasm-decompile
NODE := node
LYSC := ./node_modules/.bin/lys
EMCC := emcc
ZIGC := zig
CARGO := cargo

########
# Main #
########

all: $(WASM_LIBS) | build-harness
	$(NODE) build/run.js
.PHONY: all

wat: $(WAT_ALL)
.PHONY: wat

decompile: $(DCM_ALL)
.PHONY: decompile

################
# Wasm Helpers #
################

%.wat: %.wasm
	$(WASM2WAT) $< -o $@

%.dcm: %.wasm
	$(WASM_DCM) $< -o $@

#############
# Wasm Text #
#############

build/%.wasm: src_wat/%.wat | mkdirs
	$(WAT2WASM) $< -o $@

##############
# JavaScript #
##############

build-harness: build/run.js
.PHONY: build-harness

build/%.js: %.js | mkdirs
	@cp $< $@

#######
# Zig #
#######

build/lib-zig/%.wasm: src_zig/%.zig | mkdirs
	$(ZIGC) build-lib $< --name $(subst .wasm,,$@) -target wasm32-freestanding

# TODO currently configured as a one-off
build/lib-zig-exported/%.wasm: build/lib-zig/%.wasm
	$(WASM2WAT) $< -o $(subst .wasm,.wat,$<)
	./append-wat-snippet.sh $(subst .wasm,.wat,$<) src_wat/export-stack.wat.snip > $(subst .wasm,.wat,$@)
	$(WAT2WASM) $(subst .wasm,.wat,$@) -o $@

build/lib-zig/%.wat: build/lib-zig/%.wasm
	$(WASM2WAT) $< -o $@

zig-test: $(ZIG_SRC)
	$(ZIGC) test $<
.PHONY: zig-test

########
# Rust #
########
CARGO_OUT := target/wasm32-unknown-unknown/debug/lib_rust.wasm

build/lib-rust/lib.wasm: $(CARGO_OUT)
	cp target/wasm32-unknown-unknown/debug/lib_rust.wasm build/lib-rust/lib.wasm

$(CARGO_OUT): src_rs/lib.rs | mkdirs
	cargo build --target wasm32-unknown-unknown

########
# Meta #
########

mkdirs:
	@mkdir -p build/{lib-zig,lib-zig-exported,lib-rust}
.PHONY: mkdirs

clean:
	rm -rf build
.PHONY: clean
