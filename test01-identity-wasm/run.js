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
    const lib = await instantiateWasm(`${__dirname}/identity.wasm`)
    console.log(`lib exports =`, lib.exports)
    console.log(`identity(32) => ${lib.exports.identity(32)}`)
  }

})().catch(e => {
  console.error(e);
  process.abort(1);
})
