ZIG_LIBS := math.zig
WASM_LIBS := $(ZIG_LIBS:%.zig=build/%.wasm)

WASM_OUT := $(wildcard build/*.wasm)
WATS := $(WASM_OUT:%.wasm=%.wat)

all: $(WASM_LIBS) build-harness
	node build/run.js


run-all: $(WASM_LIBS)
	wasm-interp build/math.wasm --run-all-exports

# JavaScript

build-harness: build/run.js

build/%.js: %.js
	@cp $< $@


# Wasm Text (for debugging)

text-all: $(WATS)
	@echo $<

%.wat: %.wasm
	wasm2wat $< -o $@

# Zig

$(WASM_LIBS): build/%.wasm: %.zig | mkdirs
	zig build-lib $< --name $(subst .wasm,,$@) -target wasm32-freestanding

# Meta

mkdirs:
	@mkdir -p build
.PHONY: clean

clean:
	rm -rf build
.PHONY: clean
