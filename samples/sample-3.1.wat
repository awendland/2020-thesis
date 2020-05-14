;; ======
;; Demo 3.1 - call foreign function
;;
;; Reference: Section 3.1 in the thesis
;; Dependencies: Core WebAssembly
;; ======

;; /* lib.cpp */
;; bool isEven(int a) {
;;   return a % 2 == 0;
;; }

(module $demo01_m1
  (func $isEven (export "isEven") (param i32)
    (result i32) ;; i32 is bool (0=false, 1=true)
    (i32.rem_u (local.get 0) (i32.const 2))
    (i32.const 0)
    (i32.eq))
)
(register "demo01_m1" $demo01_m1)

;; /* main.rs */
;; 
;; extern "WASM" {
;;   pub fn isEven(a: i32) -> bool;
;; }
;;
;; pub fn main() -> bool {
;;   return isEven(4) == true; // assert
;; }

(module $demo01_m2
  (type (;0;) (func (param i32) (result i32)))
  (import "demo01_m1" "isEven" (func $isEven (type 0)))
  (func $main (export "main") (result i32)
    (i32.const 4)
    (call $isEven)
    (i32.eq (i32.const 1 (;true;))))
)
(register "demo01_m2" $demo01_m2)

(assert_return (invoke $demo01_m2 "main") (i32.const 1 (;true;)))