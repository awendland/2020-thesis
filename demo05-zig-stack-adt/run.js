const fs = require('fs');

const instantiateWasm = async (path, importObjects = {}) => {
  const source = fs.readFileSync(path);
  const typedArray = new Uint8Array(source);
  const res = await WebAssembly.instantiate(typedArray, importObjects);
  return res.instance
}

(async () => {

  // Consume ADT via JS host environment
  {
    const stackLib = await instantiateWasm(`${__dirname}/lib-zig-exported/lib.wasm`)
    console.log(`stackLib exports =`, stackLib.exports)
    const runAtMemLoc = ({memLoc, val}) => {
      const wasmRes1 = stackLib.exports['Stack.init'](memLoc)
      console.log(`Stack[${memLoc}].init() = ${wasmRes1}`)
      const wasmRes2 = stackLib.exports['Stack.push'](memLoc, val)
      console.log(`Stack[${memLoc}].push(${val}) = ${wasmRes2}`)
      const wasmRes3 = stackLib.exports['Stack.pop'](memLoc)
      console.log(`Stack[${memLoc}].pop() = ${wasmRes3}`)
    }

    runAtMemLoc({memLoc: 0, val: -3})
    runAtMemLoc({memLoc: 1, val: -6})
    runAtMemLoc({memLoc: 1, val: -9})
  }

})().catch(e => {
  console.error(e);
  process.abort(1);
})
