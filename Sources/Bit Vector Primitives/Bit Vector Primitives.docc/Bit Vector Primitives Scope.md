# Bit Vector Primitives Scope

`swift-bit-vector-primitives` is a **discipline package over the upstream `Bit`
namespace**. It does not declare a top-level namespace of its own: every type it
ships is an extension of `Bit_Primitives.Bit` (`Bit.Vector` and its variants).
Per `[MOD-017]`'s root-applicability rule, a package that EXTENDS an
upstream-owned namespace has **no zero-dep `{Domain} Primitive` root** — so this
package has **no `Bit Vector Primitive` root target**.

## Per-[MOD-017]/[MOD-031] shape

There is **no `Bit Vector Primitives Core` target** — the legacy `[MOD-001]` Core
convention is deprecated and was dissolved from this package during the L1
core-dissolution sweep (2026-06-23). Because the former Core was internal-only
(it was never a published `.library` product and had no cross-package consumers),
it was deleted outright with **no transitional shim**.

The dissolved Core's content — the base `Bit.Vector` storage type, its protocol,
its mutating/query operations, and the Ones/Zeros set-bit View + Sequence
machinery — was relocated into a single **base module**, `Bit Vector Storage
Primitives`, which the four storage-strategy variants depend on. One base module
(not a finer split) is correct here: the Ones/Zeros Views are nested members of
`Bit.Vector` that reach directly into its private word-backed storage, so they are
mechanically inseparable from the base struct per `[MOD-026]`; minting a second
module for them would either duplicate access to private storage or be a thin
re-export, which `[MOD-RENT]` forbids.

## Owner targets

- **Bit Vector Storage Primitives** — the base module. Owns `Bit.Vector`
  (`extension Bit { struct Vector }`), `Bit.Vector.Protocol`, the clear/set/toggle/
  pop/take operations, and the `Bit.Vector.Ones` / `Bit.Vector.Zeros` set-bit views
  with their `Sequence.Protocol` conformances. Declares the external modules its
  sources name directly (`Bit`, `Bit.Pack`, `Index`, `Property`, `Sequence`,
  `Iterable`, `Iterator.Primitive`, `Iterator.Chunk`).
- **Bit Vector Static Primitives** — fixed-capacity, compile-time-sized variant.
- **Bit Vector Bounded Primitives** — capacity-bounded growable variant.
- **Bit Vector Inline Primitives** — inline-storage small-buffer variant.
- **Bit Vector Dynamic Primitives** — unbounded growable variant; composes the
  Bounded and Inline variants.
- **Bit Vector Primitives** — umbrella; re-exports the base module + all four
  variants so a consumer needing the union writes `import Bit_Vector_Primitives`.
- **Bit Vector Primitives Test Support** — published test-fixtures product.

## Out of scope

- The `Bit` namespace itself, `Bit.Index`, and `Bit.Pack` are owned by upstream
  packages (`swift-bit-primitives`, `swift-bit-pack-primitives`); this package only
  extends them.
- Sparse / hierarchical / compressed bit-set representations are distinct
  disciplines and, if introduced, extract to their own sibling packages rather than
  landing here.

## Evaluation rule

Sub-target additions are evaluated against this scope.

- A proposed addition that is a **new dense `Bit.Vector` storage strategy** lands as
  a new variant target depending on `Bit Vector Storage Primitives`.
- A proposed addition that is **shared base storage / protocol / view machinery**
  intrinsic to `Bit.Vector` lands within `Bit Vector Storage Primitives`.
- A proposed addition that is a **distinct bit-set discipline** (sparse, compressed,
  hierarchical) extracts to a sibling package, not into this one.
