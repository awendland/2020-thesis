;; ======
;; JIT Test 1a - local linear memory access
;;
;; Reference: TODO
;; Dependencies: TODO
;; ======

(module $main
  (memory 16384 16384) ;; * 64 KiB pages = 1 GiB = 1,073,742,000 i8
  (func (export "_start")
    (local $idx i32)
    (loop $iter
      (i32.store8 (local.get $idx) (i32.const 42))

      (br_if $iter
        (i32.ne
          (local.tee $idx (i32.add (local.get $idx) (i32.const 1)))
          (i32.const 1000000000)))
    ))
)
