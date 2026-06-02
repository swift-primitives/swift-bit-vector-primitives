# Bit Vector Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-bit-vector-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-bit-vector-primitives/actions/workflows/ci.yml)

`Bit.Vector` — a bit set / bit array (one `Bit` per element, word-packed) in four storage flavors behind a single protocol: **Static** (fixed-size, value-backed), **Inline** (inline, capacity-typed), **Bounded** (capacity-capped, growable), and **Dynamic** (heap-backed, growable).

Pick the storage strategy that matches your size constraints; the operations — set / clear / toggle, append, subscript, `ones` / `zeros` views, population count — are the same across all four. Bits pack into `FixedWidthInteger` words via [`swift-bit-pack-primitives`](https://github.com/swift-primitives/swift-bit-pack-primitives), so N bits cost ⌈N / word-width⌉ words rather than N bytes.

---

## Key Features

- **Four storage strategies, one protocol** — `Bit.Vector.Protocol` is implemented by `Bit.Vector.Static`, `.Inline`, `.Bounded`, and `.Dynamic`. Swap the storage; the API stays put.
- **Bit set / array operations** — `append`, subscript get/set, `popLast` / `removeLast` / `removeAll`, `count` / `isEmpty`, plus `set` / `clear` / `toggle` over single indices and ranges.
- **Ones / zeros views** — `.ones` and `.zeros` iterate the set / clear bit positions lazily as `Sequence.Protocol` views — population queries without materializing an index array.
- **Word-packed storage** — bits are packed into fixed-width-integer words, so memory is ⌈N / word-width⌉ words, not N bytes or N bools.

---

## Quick Start

```swift
import Bit_Vector_Primitives

var bits = Bit.Vector.Dynamic()
bits.append(true)
bits.append(false)
bits.append(true)

bits[0]            // true
bits.count         // 3

bits[1] = true     // set a bit by index
bits.popLast()     // Optional(true)

// Build from a literal sequence of bits:
let mask = Bit.Vector.Dynamic([true, true, false, true])
mask.count         // 4
```

`Dynamic` grows on the heap; for a compile-time-fixed width use `Bit.Vector.Static`, for inline fixed capacity use `Bit.Vector.Inline`, and for capped-but-growable use `Bit.Vector.Bounded` — see Architecture.

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-bit-vector-primitives.git", branch: "main")
]
```

Add the umbrella product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Bit Vector Primitives", package: "swift-bit-vector-primitives")
    ]
)
```

Or depend on a single variant (e.g. `Bit Vector Dynamic Primitives`) — see Architecture.

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Bit Vector Primitives` | Umbrella — `Bit.Vector.Protocol` + all four variants | Most consumers |
| `Bit Vector Dynamic Primitives` | `Bit.Vector.Dynamic` — heap-backed, growable | Unknown or large size |
| `Bit Vector Bounded Primitives` | `Bit.Vector.Bounded` — capacity-capped, growable | Growth with an upper bound |
| `Bit Vector Inline Primitives` | `Bit.Vector.Inline` — inline storage, capacity-typed | Small fixed capacity, no heap |
| `Bit Vector Static Primitives` | `Bit.Vector.Static` — fixed-size, value-backed | Compile-time-fixed width |
| `Bit Vector Primitives Test Support` | Re-exports for downstream test targets | Test target only |

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Supported    |

---

## Related Packages

- [`swift-bit-pack-primitives`](https://github.com/swift-primitives/swift-bit-pack-primitives) — the word-packing layout that backs the storage.
- [`swift-bit-primitives`](https://github.com/swift-primitives/swift-bit-primitives) — `Bit`, the element type.
- [`swift-sequence-primitives`](https://github.com/swift-primitives/swift-sequence-primitives) — `Sequence.Protocol`, which the `ones` / `zeros` views conform to.
- [`swift-iterator-primitives`](https://github.com/swift-primitives/swift-iterator-primitives) — the iterators behind those views.
- [`swift-property-primitives`](https://github.com/swift-primitives/swift-property-primitives) — the fluent-accessor machinery for the view surface.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
