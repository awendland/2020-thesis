;; ======
;; Demo 3.2 - pass foreign function to other foreign function
;;
;; Reference: Section 3.2 in the thesis
;; Dependencies: Core WebAssembly
;; ======

;; /* lib.cpp */
;; bool isEven(int a) {
;;   return a % 2 == 0;
;; }

(module $demo02_m1
  (func $isEven (export "isEven") (param i32)
    (result i32) ;; i32 is bool (0=false, 1=true)
    (i32.rem_u (local.get 0) (i32.const 2))
    (i32.const 0)
    (i32.eq))
)
(register "demo02_m1" $demo02_m1)

;; /* lib.zig */
;; const const num: i32 = 53
;;
;; export fn test_num(pred: fn(i32) -> bool) -> bool {
;;   return pred(elem);
;; }

(module $demo02_m2
  (global $num i32 (i32.const 53))
  (type (;0;) (func (param i32) (result i32)))
  ;; create a table which the predicate function will be provided through
  (table $fns (export "_fns") 1 funcref)
  ;; get the index of the slot to register a func in
  (func (export "_fns_slot") (result i32) (i32.const 0))
  ;; free up the slot
  (func (export "_fns_free") (param $slot i32)
    (table.set $fns (local.get $slot) (ref.null)))
  (func $test_num (export "test_num") (param $_fn_slot i32) (result i32)
    (global.get $num)
    ;; call the predicate fn
    (call_indirect $fns (type 0) (local.get $_fn_slot)))
)
(register "demo02_m2" $demo02_m2)

;; /* main.rs */
;; 
;; extern "WASM" {
;;   pub fn test_num(pred: &dyn Fn(i32) -> bool) -> bool;
;;   pub fn isEven(a: i32) -> bool;
;; }
;;
;; pub fn main() -> bool {
;;   return test_num(isEven);
;; }

(module $demo02_m3
  (type (func (param i32) (result i32))) ;; 0
  (import "demo02_m1" "isEven" (func $isEven (type 0)))
  (import "demo02_m2" "test_num" (func $test_num (type 0)))
  (import "demo02_m2" "_fns" (table $m2_fns 1 funcref))
  (import "demo02_m2" "_fns_slot" (func $m2_fns_slot (result i32)))
  (import "demo02_m2" "_fns_free" (func $m2_fns_free (param i32)))
  ;; register the func as exportable
  (elem declare func $isEven $isEven)
  (func $main (export "main") (result i32) (local i32 i32)
    ;; pass the predicate func to $demo_m2
    (local.set 0 (call $m2_fns_slot))
    (table.set $m2_fns (local.get 0) (ref.func $isEven))
    ;; call the func
    (local.set 1 (call $test_num (local.get 0)))
    ;; cleanup the predicate func
    (call $m2_fns_free (local.get 0))
    (local.get 1))
)
(register "demo02_m3" $demo02_m3)

(assert_return (invoke $demo02_m3 "main") (i32.const 0 (;false;)))