extern crate wee_alloc;

// Use `wee_alloc` as the global allocator.
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

// https://doc.rust-lang.org/nomicon/ffi.html#representing-opaque-structs
// #[repr(C)] pub struct Stack { loc: i32 }
// #[repr(C)] pub struct Stack(i32);

// impl Drop for Stack {
//     fn drop(&mut self) {
//         unsafe {
//             Stack__deinit(self);
//         }
//     }
// }

type Stack = i32;

extern "C" {
    // NOTE: if these are set as &mut, then Rust will export Wasm that does
    // offset operations in a manner that causes Node to be
    // `terminated by signal SIGBUS (Misaligned address error)`
    pub fn Stack__init(inst: Stack);
    pub fn Stack__deinit(inst: Stack);
    pub fn Stack__push(inst: Stack, item: i32);
    pub fn Stack__pop(inst: Stack) -> i32;
}

#[no_mangle]
pub extern fn use_stack_adt(val: i32) -> i32 {
    let s1: Stack = 1;
    unsafe {
        Stack__init(s1);
        Stack__push(s1, val);
        return Stack__pop(s1);
    }
}


// Working with Duck-Typed Interfaces
// https://rustwasm.github.io/docs/wasm-bindgen/reference/working-with-duck-typed-interfaces.html
//
// extern "C" {
//     pub type Quacks;
//
//     #[wasm_bindgen(structural, method)]
//     pub fn quack(this: &Quacks) -> String;
// }
