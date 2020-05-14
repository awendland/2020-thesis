#!/bin/bash
set -ex
wat2wasm $1 -o ${1//\.wast/.wasm}
wasmtime wasm2obj ${1//\.wast/.wasm} ${1//\.wast/.o} -O
objdump -d ${1//\.wast/.o} > ${1//\.wast/.o.txt}
