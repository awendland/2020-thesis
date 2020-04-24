const fs = require('fs');

const instantiateWasm = async (path, importObjects = {}) => {
  const source = fs.readFileSync(path);
  const typedArray = new Uint8Array(source);
  const res = await WebAssembly.instantiate(typedArray, importObjects);
  return res.instance
}

(async () => {

  // Consume ADT via Rust lib
  // Example errors:
  //
  //   1. `Import #0 module="env" function="Stack__deinit" error: function import requires a callable]`
  //     * Occurs when imports cannot find appropriately named injected functions in the environment.
  //     * Replicate by removing entries from `renamedStackLibFuncs`.
  //   2. `Import #2 module="env" function="Stack__push" error: imported function does not match the expected type]`
  //     * Occurs when injected functions do not match the defined imports.
  //     * Replicate by creating functions with incorrect signatures for any of the imports (such as `Stack__init = Math.pow`
  {
    const stackLib = await instantiateWasm(`${__dirname}/lib-zig-exported/lib.wasm`)
    console.log(`stackLib exports =`, stackLib.exports)
    // Inject Stack ADT lib into Rust library
    const renamedStackLibFuncs =
      Object.entries(stackLib.exports)
        .filter(e => e[1] instanceof Function) // Remove things like 'memory'
        .map(([k, v]) => {
          // Convert name into Rust friendly form
          const safeName = k.replace(/\./g, '__')
          return [safeName, v]
        })
        .reduce((obj, [k, v]) => ({...obj, [k]: v}), {})
    console.log(`stackLib renamed =`, renamedStackLibFuncs)
    const consumerLib = await instantiateWasm(`${__dirname}/lib-rust/lib.wasm`, {
      // TODO this naming convention is one of the things that needs to be standardized
      // 1. How to make names safe for interop? (Each language can define their own rules)
      // 2. How to namespace libraries to avoid collisions?
      env: renamedStackLibFuncs,
    })
    console.log(`consumerLib exports =`, consumerLib.exports)
    const wasmRes1 = consumerLib.exports.use_stack_adt(-42)
    console.log(`use_stack_adt(-42) -> ${wasmRes1}`)
  }

})().catch(e => {
  console.error(e);
  process.abort(1);
})
