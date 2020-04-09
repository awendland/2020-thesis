;; ======
;; Demo 1 - call foreign function
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

;; ======
;; Demo 2 - pass foreign function to other foreign function
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

;; ======
;; Demo 3 - call method on foreign object
;; ======

;; /* lib.cpp */
;; class VendingMachine {
;;   private: int numCandies;
;;     return a % 2 == 0;
;; }

;; /* lib.zig */
;; const const nat_10_array: [10]i32 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
;;
;; export fn tally_nat_10(pred: fn(i32) -> bool) -> i32 {
;;   var tally = 0;
;;   for (num_array) |elem| {
;;      if (pred(elem)) tally = tally + 1;
;;   }
;;   return tally;
;; }

;; /* main.rs */
;; 
;; extern "WASM" {
;;   pub fn tally_nat_10(pred: &dyn Fn(i32) -> bool) -> i32;
;;   pub fn isEven(a: i32) -> bool;
;; }
;;
;; pub fn main() -> bool {
;;   return (tally_nat_10(isEven) == 5);
;; }

;; ======
;; Demo 4 - enforce field access modifiers
;; ======

;; ======
;; Demo 5 - maintain representation invariant
;; ======

;; /* demo05_m1.cpp */
;; class RationalNum {
;;   private:
;;     int _num, _den;
;;   public:
;;     RationalNum(int num, int den) {
;;       int gcd = std::gcd(num, den);
;;       _num = num / gcd;
;;       _den = den / gcd;
;;     }
;; }

;; (module $demo05_m1
;;   (import "std" "gcd" (func $_std_gcd (param i32) (param i32) (result i32)))
;;   (memory 1)
;;   (func $_malloc (param i32) (result i32) (i32.const 0))
;;   (abstype_new $RationalNum i32)
;;   ;; RationalNum struct = {int, int} = 4 + 4 = 8 bytes
;;   (func (export "RationalNum.new") (param $num i32) (param $den i32)
;;     (result (abstype_new_ref $RationalNum)) (local $gcd i32) (local $adr i32)
;;     (local.set $gcd (call $_std_gcd (local.get $num) (local.get $den)))
;;     (local.set $adr (call $_malloc (i32.const 8)))
;;     (i32.store offset=0 (local.get $adr) (i32.div_s (local.get $num) (local.get $gcd)))
;;     (i32.store offset=1 (local.get $adr) (i32.div_s (local.get $num) (local.get $gcd)))
;;     (local.get $adr))
;;   (func (export "RationalNum.getNumerator")
;;     (param $this (abstype_new_ref $RationalNum)) (result i32)
;;     (i32.load offset=0 (local.get $this)))
;; )

;; ======
;; Demo 6 - support generics (parameterized modules)
;; ======

;; ======
;; Demo 7 - array access
;; ======
(module $demo07_m1
  (memory 1)
  (global $nextAddr (mut i32) (i32.const 0))
  (abstype_new $Buffer i32) ;; a sequence of bytes
  (func $Buffer.create (param $size i32) (result (abstype_new_ref $Buffer))
    (local i32)
    (local.set 1 (global.get $nextAddr))
    (i32.store (local.get 1) (local.get $size))
    (global.set $nextAddr
      (i32.add (local.get 1)
        (i32.add (local.get $size) (i32.const 4))))
    (local.get 1))
  (func $Buffer.size (param $this (abstype_new_ref $Buffer)) (result i32)
    (i32.load (local.get 0)))
  (func $Buffer.i32_load (param $this (abstype_new_ref $Buffer)) (param $idx i32) (result i32)
    (i32.add (i32.add (local.get $this) (i32.const 4)) (local.get $idx))
    (i32.load))
  (func $Buffer.i32_load8_u (param $this (abstype_new_ref $Buffer)) (param $idx i32) (result i32)
    (i32.add (i32.add (local.get $this) (i32.const 4)) (local.get $idx))
    (i32.load8_u))
  (func $Buffer.i32_store (param $this (abstype_new_ref $Buffer)) (param $idx i32) (param $data i32)
    (i32.add (i32.add (local.get $this) (i32.const 4)) (local.get $idx))
    (local.get $data)
    (i32.store))
  (func $Buffer.i32_store8 (param $this (abstype_new_ref $Buffer)) (param $idx i32) (param $data i32)
    (i32.add (i32.add (local.get $this) (i32.const 4)) (local.get $idx))
    (local.get $data)
    (i32.store))
  (abstype_new $ReadonlyBuffer i32)
  (func $ReadonlyBuffer.fromBuffer (param $super (abstype_new_ref $Buffer))
    (result (abstype_new_ref $ReadonlyBuffer))
    (local.get 0))
  (func $ReadonlyBuffer.i32_load (param $this (abstype_new_ref $Buffer)) (param $idx i32) (result i32)
    (call $Buffer.i32_load (local.get $this) (local.get $idx)))
  (func $ReadonlyBuffer.i32_load8_u (param $this (abstype_new_ref $Buffer)) (param $idx i32) (result i32)
    (call $Buffer.i32_load8_u (local.get $this) (local.get $idx)))
)
(register "demo07_m1" $demo07_m1)
