# Vision

## Usage

### Simple ADT (no parameterized types)

`Lib.wat` (exported by some source language OR written by hand)

```lisp
(module
  (type $Stack_i32) i32)
  (func $Stack_i32.constructor (result (ref $Stack_i32)) ...)
  (func $Stack_i32.destruct (param (ref $Stack_i32)) ...)
  (func $Stack_i32.push (param (ref $Stack_i32)) (param i32) ...)
  (func $Stack_i32.pop (param (ref $Stack_i32)) (result i32) ...)
  (export ...)
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

## TODO

1. Define destructor naming convention.
    * Motivation: Rust has a `Drop` trait that will called (when available) when a reference exits scope. Having a standard convention for referring to destructors would allow this trait to be implemented automatically.
        * Alternative: Expand macro to optionally take the name of a destructor function with the signature `(&self) -> nil`.
2. Define name-mangling conventions so that names are usable by all source languages.
        * Motivation: Rust can't reference extern functions that have `.` in the name.

## Questions

1. How should _Generics_/_Paramaterized Types_ be handled?
2. Where should ADT instances be stored?
    * Within Wasm Modules private memory?
        * Pro: Abstraction is easier to enforce.
        * Pro: Less work on the caller.
        * Con: Poor cache performance when working with instances from multiple libraries.
        * Con: If library uses GC and consumer doesn't, intermixes different memory management conventions.
3. How to propagate errors between languages?

## Notes

* Wasm Modules and reftypes are the primitives needed to implement this.
    * Wasm Modules enforced interface adherence and (mostly) hides underyling memory.
    * reftypes enable opaque ADT instance identification without having to refer to memory locations.
        * Could be circumvented with a mapping table, but reftypes are more convenient due to export/import capabilities and param references (to strengthen signature type checking).
