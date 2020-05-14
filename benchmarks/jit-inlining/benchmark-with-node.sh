#!/bin/bash
set -ex

./compile-and-run.js ./node-wasm-bench.js main:jit-test-1a.wast
./compile-and-run.js ./node-wasm-bench.js main:jit-test-1b.wast
./compile-and-run.js ./node-wasm-bench.js lib:jit-test-1c-lib.wast main:jit-test-1c-main.wast
