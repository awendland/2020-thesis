;; ======
;; Demo 4.2 - array access
;;
;; Reference: Section 3.6 and Appendix A.2 in the thesis
;; Dependencies: Core WebAssembly + abstract types (https://github.com/awendland/webassembly-spec-abstypes)
;; ======
(module $lib_buffer
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
(register "lib_buffer" $lib_buffer)