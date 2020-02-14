const fs = require('fs');

const instantiateWasm = async (path, importObjects = {}) => {
  const source = fs.readFileSync(path);
  const typedArray = new Uint8Array(source);
  const res = await WebAssembly.instantiate(typedArray, importObjects);
  return res.instance
}

(async () => {

  const addLib = await instantiateWasm(`${__dirname}/add.wasm`)
  const subLib = await instantiateWasm(`${__dirname}/sub.wasm`)
  const wasmRes = subLib.exports.sub(addLib.exports.add(1, 2), 7)
  console.log(`(1 + 2) - 7 = ${wasmRes}\n`
            + `|_____| |__|\n`
            + ` zig    rust`)

})().catch(e => {
  console.error(e);
  process.abort(1);
})
