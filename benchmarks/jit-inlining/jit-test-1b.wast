;; ======
;; JIT Test 1b - function call linear memory access
;;
;; Reference: TODO
;; Dependencies: Core WebAssembly
;; ======

(module $main
  (memory 16384 16384) ;; * 64 KiB pages = 1 GiB = 1,073,742,000 i8
  (func $set (param i32) (param i32)
    (i32.store8 (local.get 0) (local.get 1)))
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
