# C64 FNV-1a hasher

Here's an implementation of the 64bit FNV-1a hash for the C64. This
implementation assumes NUL-terminated input (C-style strings), but could
easily be modified to accept arbitrary input. It tries to balance code size
and speed, and it's verified with a list of sample inputs against several
reference implementations.

**Files**:

* `test.s`: A simple test program hashing a line of input from the keyboard,
  exit by entering an empty line
* `fnv1a.s`: An optimized implementation of the FNV-1a algorithm for the
  MOS 6502.
* `ref.c`: Simple reference implementation in C, **not** for the C64

## Screenshot

![fnv1a test run](https://github.com/Zirias/c64_fnv1a/blob/master/test.png?raw=true)

## Building

To build, you need GNU make and the cc65 cross compiler installed. Then just
type `make` (or `gmake`).
