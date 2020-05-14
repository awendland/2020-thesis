;; ======
;; JIT Test 1c - Main - cross-module linear memory access
;;
;; Reference: TODO
;; Dependencies: Core WebAssembly
;; ======

(module $main
  (import "lib" "set" (func $set (param i32) (param i32)))
  (func (export "_start")
    (local $idx i32)
    (loop $iter
      (call $set (local.get $idx) (i32.const 42))

      (br_if $iter
        (i32.ne
          (local.tee $idx (i32.add (local.get $idx) (i32.const 1)))
          (i32.const 1000000000)))
    ))
)
