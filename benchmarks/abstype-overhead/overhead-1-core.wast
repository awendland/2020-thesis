(module $lib
  (func (export "createToken") (result i32)
    (i32.const 42))
  (func (export "getValue") (param $token i32) (result i32)
    (local.get $token))
)
(register "lib" $lib)

(module $main
  (import "lib" "createToken" (func $createToken (result i32)))
  (import "lib" "getValue" (func $getValue (param i32) (result i32)))
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
