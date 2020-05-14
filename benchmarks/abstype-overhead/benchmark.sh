#!/bin/bash

while true; do
  time_core=$(command time $WASM_CORE overhead-1-core.wast 2>&1 | egrep -oh '\d+.\d+ user' | egrep '\d+.\d+' -oh)
  printf "abstypes\t${time_core}\n"
  time_abs=$(command time $WASM_ABSTYPES overhead-1-abstype.wast 2>&1 | egrep -oh '\d+.\d+ user' | egrep '\d+.\d+' -oh)
  printf "baseline\t${time_abs}\n"
done
