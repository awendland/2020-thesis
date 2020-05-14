#!/bin/bash

while true; do
  time_baseline=$(command time $WASM_CORE overhead-1-core.wast 2>&1 | egrep -oh '[0-9]+.[0-9]+[[:space:]]*user' | egrep '[0-9]+.[0-9]+' -oh)
  printf "baseline\t${time_baseline}\n"
  time_core=$(command time $WASM_ABSTYPES overhead-1-core.wast 2>&1 | egrep -oh '[0-9]+.[0-9]+[[:space:]]*user' | egrep '[0-9]+.[0-9]+' -oh)
  printf "no-abstypes\t${time_core}\n"
  time_abs=$(command time $WASM_ABSTYPES overhead-1-abstype.wast 2>&1 | egrep -oh '[0-9]+.[0-9]+[[:space:]]*user' | egrep '[0-9]+.[0-9]+' -oh)
  printf "abstypes\t${time_abs}\n"
done
