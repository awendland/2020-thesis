ZIG_LIBS := src_zig/lib.zig
LYS_LIBS := src_lys/kaccek-api.lys
CPP_LIBS := src_cpp/lib.cpp

ZIG_WASM := $(ZIG_LIBS:src_zig/%.zig=build/lib-zig/%.wasm)
LYS_WASM := $(LYS_LIBS:src_lys/%.lys=build/lib-lys/%.wasm)
CPP_WASM := $(CPP_LIBS:src_cpp/%.cpp=build/lib-cpp/%.wasm)
WASM_LIBS := $(ZIG_WASM) $(LYS_WASM) $(CPP_WASM)

WASM_OUT := $(wildcard build/*.wasm)
WATS := $(WASM_OUT:%.wasm=%.wat)

$LYSC := ./node_modules/.bin/lys
$EMCC := emcc
$ZIGC := zig

all: $(WASM_LIBS)
	@cargo run
.PHONY: all

run-all: $(WASM_LIBS)
	$(foreach wasmf,$(WASM_OUT),wasm-interp $(wasmf) --run-all-exports;)
.PHONY: run-all

# Wasm Text (for debugging)

wat: $(WATS)
	@echo $<
.PHONY: text-all

%.wat: %.wasm
	wasm2wat $< -o $@

# Zig

build/lib-zig/%.wasm: %.zig | mkdirs
	$(ZIGC) build-lib $< --name $(subst .wasm,,$@) -target wasm32-freestanding

# Lys

build/lib-lys/%.wasm: %.lys | mkdirs
	$(LYSC) $< --output $(basename, $@)

# C++

build/lib-cpp/%.wasm: %.cpp | mkdirs
	$(EMCC) $< -std=c++17 -s LEGALIZE_JS_FFI=0 -r -o $@ -s WASM=1 -s DISABLE_EXCEPTION_CATCHING=0 -s -s EXPORT_ALL=1

# Meta

mkdirs:
	@mkdir -p build/lib-{zig,lys,cpp}
.PHONY: mkdirs

clean:
	rm -rf build
.PHONY: clean
