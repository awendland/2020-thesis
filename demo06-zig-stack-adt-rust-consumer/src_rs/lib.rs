extern crate wee_alloc;

// Use `wee_alloc` as the global allocator.
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

// https://doc.rust-lang.org/nomicon/ffi.html#representing-opaque-structs
#[repr(C)] pub struct Stack { loc: i32 }

impl Drop for Stack {
    fn drop(&mut self) {
        unsafe {
            Stack__deinit(self);
        }
    }
}

extern "C" {
    pub fn Stack__init(inst: &mut Stack);
    pub fn Stack__deinit(inst: &mut Stack);
    pub fn Stack__push(inst: &mut Stack, item: i32);
    pub fn Stack__pop(inst: &mut Stack) -> i32;
}

#[no_mangle]
pub extern fn use_stack_adt(val: i32) -> i32 {
    let mut s1 = Stack { loc: 1 };
    unsafe {
        Stack__init(&mut s1);
        Stack__push(&mut s1, val);
        return Stack__pop(&mut s1);
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
