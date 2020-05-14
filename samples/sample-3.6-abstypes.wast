;; ======
;; Demo 3.6 - simplified fraction representation invariant
;;
;; Reference: Section 3.6 in the thesis
;; Dependencies: Core WebAssembly + abstract types (https://github.com/awendland/webassembly-spec-abstypes)
;; ======

;; Simple gcd implementation to polyfill C++ std::gcd
(module $demo03_std
  (func $gcd (export "gcd") (param $a i32) (param $b i32) (result i32)
    (if (result i32) (i32.eq (local.get $a) (i32.const 0))
      (then (local.get $b))
      (else
        (call $gcd
            (i32.rem_s (local.get $b) (local.get $a))
            (local.get $a)))))
)
(register "std" $demo03_std)

;; /* demo03_m1.cpp */
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

(module $demo03_m1
  (import "std" "gcd" (func $_std_gcd (param i32) (param i32) (result i32)))
  (memory 1)
  (func $_malloc (param i32) (result i32)
    ;; Only support a single allocation for this toy example
    ;; i.e. ignore size and return the same i32 address every time
    (i32.const 0))
  (abstype_new $RationalNum i32)
  ;; RationalNum struct = {int, int} = 4 + 4 = 8 bytes
  (func (export "RationalNum.new") (param $num i32) (param $den i32)
    (result (abstype_new_ref $RationalNum)) (local $gcd i32) (local $adr i32)
    (local.set $gcd (call $_std_gcd (local.get $num) (local.get $den)))
    (local.set $adr (call $_malloc (i32.const 8)))
    (i32.store offset=0 (local.get $adr)
      (i32.div_s (local.get $num) (local.get $gcd)))
    (i32.store offset=4 (local.get $adr)
      (i32.div_s (local.get $num) (local.get $gcd)))
    (local.get $adr))
  (func (export "RationalNum.getNumerator")
    (param $this (abstype_new_ref $RationalNum)) (result i32)
    (i32.load offset=0 (local.get $this)))
  (export "RationalNum" (abstype_new_ref $RationalNum))
)
(register "demo03_m1" $demo03_m1)


(module $demo03_test
  (import "demo03_m1" "RationalNum" (abstype_sealed $RationalNum))
  (import "demo03_m1" "RationalNum.new" (func $RationalNum.new
    (param i32) (param i32) (result (abstype_sealed_ref $RationalNum))))
  (import "demo03_m1" "RationalNum.getNumerator" (func $RationalNum.getNumerator
    (param (abstype_sealed_ref $RationalNum)) (result i32)))
  (func (export "main") (result i32)
    (local $ratio (abstype_sealed_ref $RationalNum))
    (local.set $ratio
      (call $RationalNum.new (i32.const 10) (i32.const 2)))
    (; e.g. perform other operations w/ $ratio (which is "5/2") ;)
    (call $RationalNum.getNumerator (local.get $ratio))
  )
)

(assert_return (invoke $demo03_test "main") (i32.const 5))
