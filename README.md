# wasm-thesis

## Dependencies

_Focused on configuration for a macOS development machine, but all toolchain componenets should be available on Linux and Windows as well._

* Runtimes
  * wasm-interp (wabt | macos: brew)
* Compilers
  * General Wasm/Wat (wabt | macos: brew)
  * CPP (emscripten | macos: brew)
    * Also need binaryen (macos: yarn)
    * Update `~/.emscripten` to link to:
      * llvm from brew (LLVM_ROOT = `/usr/local/Cellar/llvm/9.0.1/bin`)
      * binaryen from yarn/npm global (BINARYEN_ROOT = `/usr/local/bin`)
  * Rust (rustup | macos: brew)
    * `rustup target add wasm32-unknown-unknown`
  * Zig (zig | macos: brew)
