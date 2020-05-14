(module $lib
  (abstype_new $Token i32)
  (func (export "createToken") (result (abstype_new_ref $Token))
    (i32.const 42))
  (func (export "getValue") (param $token (abstype_new_ref $Token)) (result i32)
    (local.get $token))
  (export "Token" (abstype_new_ref $Token))
)
(register "lib" $lib)

(module $main
  (import "lib" "Token" (abstype_sealed $Token))
  (import "lib" "createToken" (func $createToken (result (abstype_sealed_ref $Token))))
  (import "lib" "getValue" (func $getValue (param (abstype_sealed_ref $Token)) (result i32)))
  (func (export "_start")
    (local $idx i32)
    (loop $iter
      (call $getValue (call $createToken))
      (drop)
      (br_if $iter
        (i32.ne
          (local.tee $idx (i32.add (local.get $idx) (i32.const 1)))
          (i32.const 1)))
    ))
)
(invoke $main "_start")
