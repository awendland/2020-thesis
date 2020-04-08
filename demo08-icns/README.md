Run `make` to see a Stack ADT implemented in Zig consumed in the JS host environment.

In `run.js` the Stack is created, an item is pushed onto it, and the item is popped up. This is done at several memory locations to show that multiple Stack instances can be created.

## Notes

1. Because the JS is also the host environment, it could violate the ADT and manipulate memory directly, however, if the consumer was another Wasm module then the interface would be enforced (by the host environment).
2. The Stack instances are kept in memory managed by the Zig module. How does this impact the usability of the ADT?
3. References to the Stack instances are maintained via an i32 value, which is passed to the Stack ADT methods. This would ideally be abstracted away and users would call methods directly on the ADT instance in their programming language like normal.

## Build Pipeline

Some hokey stuff is going on to make the Stack ADT in Zig exported in the generated Wasm module. You can see the pre-export intermediary in `build/lib-zig/` and the post-export final version in `build/lib-zig-exported/`. All that's happening is export instructions are appended to the intermediary mannually (see `src_wat/export-stack.wat.snip` for what's getting added and `append-wat-snippet.sh` for what's doing the adding).
