;; ======
;; JIT Test 1b - Library - cross-module linear memory access
;;
;; Reference: TODO
;; Dependencies: Core WebAssembly
;; ======

(module $lib
  (memory 16384 16384) ;; * 64 KiB pages = 1 GiB = 1,073,742,000 i8
  (func (export "set") (param i32) (param i32)
    (i32.store8 (local.get 0) (local.get 1)))
)
