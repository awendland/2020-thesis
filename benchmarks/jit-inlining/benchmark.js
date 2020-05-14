#!/usr/bin/env node

// compile-and-run.js
//
// USAGE: compile-and-run.js PATH_TO_RUNNER [LIB_ID:LIB_PATH [...]] main:MAIN_PATH
//
// Any *_PATHs that end in .wast will be compiled using `wasm-opt -O4` to .wasm binaries.

const child_process = require('child_process')
const fs = require('fs')

const data_extract = /(\d\S).+?.wasm[\s\S]+?run time: (\d+\.?\d*m?s)/gm

async function main() {
  while (true) {
    for (const benchmark_type of ['wasmtime', 'node']) {
      let stdout = ''
      await new Promise((resolve, reject) => {
        const sh = child_process.exec(`./benchmark-with-${benchmark_type}.sh`,
          (err) => err ? reject(err) : resolve())
        sh.stdout.on('data', chunk => stdout += chunk.toString())
        sh.stderr.on('data', chunk => stdout += chunk.toString())
      })
      let match = data_extract.exec(stdout)
      while (match != null) {
        const [, id, time_s] = match
        const time = (() => {
          if (time_s.includes('ms')) return Number.parseFloat(time_s.replace('ms', ''))
          if (time_s.includes('s')) return Number.parseFloat(time_s.replace('s', '')) * 1000
          return `INVALID=${time_s}`
        })()
        console.log(`${benchmark_type}\t${id}\t${time}\n`)
        match = data_extract.exec(stdout)
      }
    }
  }
}
main().catch(e => {console.error(e); process.exit(1)})
