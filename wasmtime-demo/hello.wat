(;; wat2wasm hello.wat -o $WASM_FILES/hello.wasm ;;)
(module
  (func (export "answer") (result i32)
     i32.const 42
  )
)
