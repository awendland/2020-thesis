#!/usr/bin/env node

// compile-and-run.js
//
// USAGE: compile-and-run.js PATH_TO_RUNNER [LIB_ID:LIB_PATH [...]] main:MAIN_PATH
//
// Any *_PATHs that end in .wast will be compiled using `wasm-opt -O4` to .wasm binaries.

const child_process = require('child_process')

let new_args = []

for (const arg of process.argv.slice(3)) {
  let [name, path] = arg.split(':')
  if (path.includes('.wast')) {
    const watpath = path
    path = watpath.replace('.wast', '.wasm')
    const cmd = `wasm-opt -O4 ${watpath} -o ${path}`
    console.warn(cmd)
    child_process.execSync(cmd, {stdio: 'inherit'})
  }
  new_args.push(`"${name}:${path}"`)
}

child_process.execSync(`${process.argv[2]} ${new_args.join(" ")}`, {stdio: 'inherit'})
