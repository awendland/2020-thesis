Run `cargo run` to see interop between `src/main.rs` and `hello.wat`.

NOTE: `hello.wat` must be converted to binary format first using `wat2wasm hello.wat -o hello.wasm`.

Based on:

1. https://hacks.mozilla.org/2019/12/using-webassembly-from-dotnet-with-wasmtime/
  a. https://bytecodealliance.github.io/wasmtime/embed-rust.html
