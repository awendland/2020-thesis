# JIT Inlining Tests

Perform linear memory stores in several different configurations:

* WebAssembly features
  1. Directly within the loop - *jit-test-1a.wast*
  2. In a function called from the loop - *jit-test-1b.wast*
  3. In a function in a separate module imported and called from the loop - *jit-test-1c-\*.wast*
* JIT Engines
  * Node.js's WebAssembly engine i.e. v8 - *node-wasm-bench.js*
  * wasmtime's engine, built on cranelift - *rust-wasm-bench, built using cargo*

## Execution

Call `benchmark-with-node.sh` or `benchmark-with-wasmtime.sh` to run each *jit-test-1\*.wast* test. These will compile the *\*.wast* files using `wasm-opt -O4` and then run them using the aforementioned engines.
