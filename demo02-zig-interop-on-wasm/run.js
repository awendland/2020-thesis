const fs = require('fs');
const source = fs.readFileSync(`${__dirname}/math.wasm`);
const typedArray = new Uint8Array(source);

WebAssembly.instantiate(typedArray, {
  // Environment to inject into Wasm modules
  env: {
    print: (result) => { console.log(result); }
  }
}).then(result => {
  // Use the Wasm module
  const add = result.instance.exports.add;
  console.log(add(1, 2));
});
