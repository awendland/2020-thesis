const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;
const mem = std.mem;
const Allocator = mem.Allocator;

export fn entry_point() i32 {
  var stack1 = Stack.init();
  defer stack1.deinit();
  stack1.push(-3) catch unreachable;
  var stack2 = Stack.init();
  defer stack2.deinit();
  stack2.push(-9) catch unreachable;
  return stack2.pop();
}

pub fn DefaultAllocator() *Allocator {
  var bytes: [8192]u8 = undefined;
  return &std.heap.FixedBufferAllocator.init(bytes[0..]).allocator;
}

pub const Stack = struct {
  const Self = @This();

  items: []i32,
  len: usize,
  allocator: *Allocator,

  /// Deinitialize with `deinit`.
  pub fn init() Self {
    return Self{
      .items = &[_]i32{},
      .len = 0,
      .allocator = DefaultAllocator(),
    };
  }

  /// Release all allocated memory.
  pub fn deinit(self: Self) void {
    self.allocator.free(self.items);
  }

  fn capacity(self: Self) usize {
    return self.items.len;
  }

  /// Add 1 item to the top of the stack. Allocates more memory as
  /// necessary.
  pub fn push(self: *Self, item: i32) !void {
    const new_length = self.len + 1;
    try self.ensureCapacity(new_length);
    assert(self.len < self.capacity());
    const result = &self.items[self.len];
    self.len += 1;
    const new_item_ptr = result;
    new_item_ptr.* = item;
  }

  fn ensureCapacity(self: *Self, new_capacity: usize) !void {
    var better_capacity = self.capacity();
    if (better_capacity >= new_capacity) return;
    while (true) {
      better_capacity += better_capacity / 2 + 8;
      if (better_capacity >= new_capacity) break;
    }
    self.items = try self.allocator.realloc(self.items, better_capacity);
  }

  /// Remove and return the last element from the stack. Asserts
  /// the stack has at least one item.
  pub fn pop(self: *Self) i32 {
    self.len -= 1;
    return self.items[self.len];
  }

  /// Determine the number of items on the stack
  pub fn size(self: *Self) usize {
    return self.len;
  }
};

test "std.Stack.init" {
  var stack = Stack.init();
  defer stack.deinit();

  testing.expect(stack.len == 0);
  testing.expect(stack.capacity() == 0);
}

test "std.Stack.basic" {
  var stack = Stack.init();
  defer stack.deinit();

  {
    var i: usize = 0;
    while (i < 10) : (i += 1) {
      stack.push(@intCast(i32, i + 1)) catch unreachable;
    }
  }

  {
    var i: usize = 0;
    while (i < 10) : (i += 1) {
      testing.expect(stack.items[i] == @intCast(i32, i + 1));
    }
  }

  testing.expect(stack.pop() == 10);
  testing.expect(stack.pop() == 9);
  testing.expect(stack.len == 8);
}
