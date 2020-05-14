#!/usr/bin/env node
const fs = require('fs')
const child_process = require('child_process')

async function main() {
  let modules = {}
  for (const arg of process.argv.slice(2)) {
    let [name, path] = arg.split(':')
    if (path.includes('.wast')) {
      const watpath = path
      path = watpath.replace('.wast', '.wasm')
      const cmd = `wasm-opt -O4 ${watpath} -o ${path}`
      console.warn(cmd)
      child_process.execSync(cmd)
    }
    const source = fs.readFileSync(path);
    const typedArray = new Uint8Array(source);
    const {instance} = await WebAssembly.instantiate(typedArray, modules)
    Object.assign(modules, {[name]: instance.exports})
  }
  console.warn(`warming jit...`)
  modules['main']._start() // warm up JIT
  modules['main']._start() // warm up JIT
  console.time("run time")
  modules['main']._start()
  console.timeEnd("run time")

}
main().catch(e => { console.error(e); process.exit(1) })
