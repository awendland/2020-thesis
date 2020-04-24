# Exploring Sound, Polyglot FFI via Wasm

**End Goal**: Provide practical, sound interop between programming languages on top of WebAssembly.

**Exploration Goal**: What does WebAssembly currently provide for sound interop?

## Index

* `demo*/`
   * `demo01` - Embed a WebAssembly inside a Rust program an run a trivial WebAssembly script (`hello.wat`).
   * `demo02` - Compile a trivial addition function (i.e. `(a: i32, b: i32) => a + b`) in Zig to WebAssembly and run it via a JavaScript host runtime.
   * `demo03` - Use the `demo02` addition function, compile a trivial subtraction function (i.e. `(a: i32, b: i32) => a - b`) in Rust to WebAssembly, and compose them in a JavaScript host runtime.
   * `demo04` - WIP 3-way w/ Zig, Lys, Rust
   * `demo05` - Compile a simple stack implementation in Zig to WebAssembly and use it via a JavaScript host runtime.
   * `demo06` - Consume the `demo05` stack implementation with a Rust function compiled to WebAssembly and running on a JavaScript host runtime.
* `test01` - Trivial identify function in WebAssembly for testing signature types and runtime conversions.

## Usage

Each of the `demo*` folders should be usable via `make`. Simply running `make` will build anything required using the appropriate toolchain (see [Dependencies]) and then run the demo.

## Object Interop Vision

NOTE: this syntax was inspired by proposals that have not been accepted: [GC](https://github.com/WebAssembly/gc/blob/master/proposals/gc/Overview.md) (reference types, type imports, typed function references).


### Simple ADT (no parameterized types)

`Lib.wat` (exported by some higher-level source language OR written by hand)

TODO: represent in a higher-level source language for better end-to-end understanding.

```lisp
(module
  (type $Stack_i32 i32)
  (func $Stack_i32.constructor (result (ref $Stack_i32)) ...)
  (func $Stack_i32.destruct (param (ref $Stack_i32)) ...)
  (func $Stack_i32.push (param (ref $Stack_i32)) (param i32) ...)
  (func $Stack_i32.pop (param (ref $Stack_i32)) (result i32) ...)
  (export ...))
```

---

`Consumer.rs`

```rust
#[extern_adt]
impl Stack_i32 {
  fn constructor() -> Stack_i32;
  fn destruct(&self) -> Stack_i32;
  fn push(&self, i32); // NOTE: this could throw an error if insufficient memory is available
  fn pop(&self) -> i32;
}
```

### Parameterized ADTs

`Lib.wat`

NOTE: This module will have to be reinstantiated for each unique `Stack__T` type.

```lisp
(module
  (import "env" "Stack__T" (type $Stack__T))
  (type $Stack i32)
  (func $Stack.constructor (result (ref $Stack)) ...)
  (func $Stack.destruct (param (ref $Stack)) ...)
  (func $Stack.push (param (ref $Stack)) (param (ref $Stack__T)) ...)
  (func $Stack.pop (param (ref $Stack)) (result (ref $Stack__T)) ...)
  (export ...))
```

---

`Consumer.rs`

```rust
#[extern_adt]
impl Stack<T> {
  fn constructor() -> Stack<T>;
  fn destruct(&self) -> Stack<T>;
  fn push(&self, T); // NOTE: this could throw an error if insufficient memory is available
  fn pop(&self) -> T;
}

pub struct Person {
  age: u8,
  name: String,
}
```

## TODO

1. Define destructor naming convention.
    * Motivation: Rust has a `Drop` trait that will called (when available) when a reference exits scope. Having a standard convention for referring to destructors would allow this trait to be implemented automatically.
        * Alternative (Rust): Expand macro to optionally take the name of a destructor function with the signature `(&self) -> nil`.
    * Existing Work: GC proposal briefly mentions a possible extension [Weak References and Finalization](https://github.com/WebAssembly/gc/blob/master/proposals/gc/Overview.md#possible-extension-weak-references-and-finalisation).
2. Define name-mangling conventions so that names are usable by all source languages.
        * Motivation: Rust can't reference extern functions that have `.` in the name.
3. Define host environment conventions for when to reinstantiate a module vs. when to reuse an existing one.
    * This is a performance optimization, the safe approach is to reinstantiate with every use.
4. Define host environment conventions for namespacing modules.
    * Existing Work: Passing remark from core team at [tool-conventions#135](https://github.com/WebAssembly/tool-conventions/issues/135#issuecomment-585426556)

### Questions

1. How should _Generics_/_Paramaterized Types_ be handled?
    * Existing Work: GC proposal has an unfinished section about a possible extension [Type Parameters and Fields](https://github.com/WebAssembly/gc/blob/master/proposals/gc/Overview.md#possible-extension-type-parameters-and-fields).
2. Where should ADT instances be stored?
    * Within Wasm Modules private memory?
        * Pro: Abstraction is easier to enforce.
        * Pro: Less work on the caller.
        * Con: Poor cache performance when working with instances from multiple libraries.
        * Con: If library uses GC and consumer doesn't, intermixes different memory management conventions.
    * The [GC proposal](https://github.com/WebAssembly/gc/blob/master/proposals/gc/Overview.md) appears to want to integrate ADTs with the GC system.
3. How to propagate errors between languages?

### Notes

* Wasm Modules and abstract types are the primitives needed to implement this.
    * Wasm Modules enforced interface adherence and (mostly) hides underyling memory.
    * Abstrac types enable opaque object instance identification without having to refer to memory locations.
        * ~~Could be circumvented with a mapping table, but abstract types are more convenient due to export/import capabilities and param references (to strengthen signature type checking).~~ See Section 2.1 in my thesis on why mapping tables are insufficient.

## Dependencies

_Focused on configuration for a macOS development machine, but all toolchain componenets should be available on Linux and Windows as well._

* Runtimes
  * wasm-interp (wabt | macos: [brew](https://formulae.brew.sh/formula/wabt))
  * node (node | macos: [brew](https://formulae.brew.sh/formula/node), fish: [nvm](https://github.com/jorgebucaran/fish-nvm))
* Compilers
  * General Wasm/Wat (wabt | macos: [brew](https://formulae.brew.sh/formula/wabt))
  * CPP (emscripten | macos: [emsdk](https://emscripten.org/docs/tools_reference/emsdk.html))
    * Deprecated approach: `brew install emscripten`
      * Also need binaryen (macos: yarn)
      * Update `~/.emscripten` to link to:
        * llvm from brew (LLVM_ROOT = `/usr/local/Cellar/llvm/9.0.1/bin`)
        * binaryen from yarn/npm global (BINARYEN_ROOT = `/usr/local/bin`)
      * FIX: unable to find `wasm-emscripten-finalize` when installed this way
  * Rust (rustup | macos: [brew](https://formulae.brew.sh/formula/rustup-init#default))
    * `rustup target add wasm32-unknown-unknown`
  * Zig (zig | macos: [brew](https://formulae.brew.sh/formula/zig))
