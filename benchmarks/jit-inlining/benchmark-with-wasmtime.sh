#!/bin/bash
set -ex

RUST_BENCH=target/release/rust-wasm-bench
if [ ! -f "$RUST_BENCH" ]; then
  cargo build --release
fi

./compile-and-run.js "$RUST_BENCH" main:jit-test-1a.wast
./compile-and-run.js "$RUST_BENCH" main:jit-test-1b.wast
./compile-and-run.js "$RUST_BENCH" lib:jit-test-1c-lib.wast main:jit-test-1c-main.wast
