// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Bit_Vector_Primitives
import Bit_Vector_Primitives_Test_Support
import Cardinal_Primitives
import Iterator_Chunk_Primitives
import Iterator_Primitive
import Testing

// MARK: - #3 negative control: escaping `ones`/`zeros` past the vector must be rejected
//
// This repository's testing conventions have no "must fail to compile" fixture
// harness (no trybuild-style support target — see the swift-property-primitives
// `Property.Consume.State Tests.swift` precedent), so the rejection is
// documented here as a commented, non-compiling control rather than invented
// ad hoc as an always-passing test.
//
// Reproduced with a standalone reduced-shape probe (`swiftc -typecheck
// -swift-version 6 -enable-experimental-feature Lifetimes
// -enable-experimental-feature LifetimeDependence -strict-memory-safety`,
// Apple Swift 6.3.3, swift-6.3.3-RELEASE) mirroring `Bit.Vector`'s
// `~Copyable` owner / `Ones.View`'s `Copyable, ~Escapable`,
// lifetime-dependent-on-the-owner shape — not compiled against the real
// dependency graph, which requires the package's full SwiftPM resolution
// (forbidden here as evidence; see the workspace skill). The reduced probe's
// `View.init(owner: borrowing Owner)` tagged `@_lifetime(borrow owner)`, and
// `Owner.view { @_lifetime(borrow self) borrowing get { View(owner: self) } }`,
// is exactly the shape `Bit.Vector.Ones.View.init(vector:)` /
// `Bit.Vector.ones` (and the `Zeros` counterparts) now use.
//
// ```swift
// // MUST NOT COMPILE. If this starts compiling clean, `ones`/`zeros` have
// // stopped being lifetime-dependent on their owning vector — the
// // use-after-free the issue swift-primitives/swift-bit-vector-primitives#3
// // fixed has regressed.
// func f() -> Bit.Vector.Ones.View {
//     let bits = Bit.Vector(capacity: 8)
//     return bits.ones
// }
// // error: a function with a ~Escapable result needs a parameter to depend on
// // note: '@_lifetime(immortal)' can be used to indicate that values produced
// //       by this initializer have no lifetime dependencies
// ```
//
// Do not uncomment this into a real, always-passing test: a function
// returning `Bit.Vector.Ones.View` with no parameter for it to depend on is
// exactly the shape this comment documents as rejected, so it cannot live as
// executable Swift in this file without breaking the build.

// MARK: - #3 (reopened) negative control: escaping the scalar `Iterator` past
// the vector must be rejected
//
// Residue of the fix above: `Bit.Vector.Ones.View.Iterator` / `Zeros.View.
// Iterator` were fully `Escapable` (via `Swift.IteratorProtocol`, which pins
// `Escapable`), so `v.ones.makeIterator()` could escape the vector with zero
// diagnostics — ASan proved the resulting heap-use-after-free in
// `Iterator.next()`. The corrective: `Iterator` is now `Copyable, ~Escapable`
// (dropping `Swift.IteratorProtocol`, keeping the `Iterator_Primitive.Iterator.
// `Protocol`` conformance that supplies `next()`), `init(view:)` is tagged
// `@_lifetime(copy view)`, and both `makeIterator()` and
// `iterableMakeIterator()` are tagged `@_lifetime(copy self)`.
//
// Verified against the real package (Apple Swift 6.3.3, swift-6.3.3-RELEASE):
// escape is now rejected by the mandatory SIL lifetime-dependence diagnostic
// pass — not by `-typecheck`, which passes this snippet clean (confirmed:
// `swiftc -typecheck` against the built module emits nothing for the snippet
// below; only `-emit-sil` / a real `swift build` surfaces the rejection).
//
// ```swift
// // MUST NOT COMPILE. If this starts compiling clean, the scalar iterator
// // has stopped being lifetime-dependent on its owning vector — the
// // heap-use-after-free this reopening fixed has regressed.
// func scalarIteratorEscape() {
//     var iterator: Bit.Vector.Ones.View.Iterator
//     do {
//         let bits = Bit.Vector(capacity: 8)
//         iterator = bits.ones.makeIterator()
//     }
//     _ = iterator.next()
// }
// // error: lifetime-dependent variable 'iterator' escapes its scope
// //  note: it depends on the lifetime of variable 'bits'
// //  note: this use of the lifetime-dependent value is out of scope
// ```
//
// Do not uncomment this into a real, always-passing test: it is exactly the
// escape shape the reopening fixed, so it cannot live as executable Swift in
// this file without breaking the build.

extension Bit.Vector {
    @Suite("Bit.Vector Tests")
    struct Test {
        @Test
        func `Create empty vector`() {
            let bits = Bit.Vector(capacity: .zero)
            #expect(bits.capacity == .zero)
            #expect(bits.isEmpty == true)
            #expect(bits.popcount == .zero)
        }

        @Test
        func `Create and access bits`() {
            let capacity: Bit.Index.Count = 100
            let bits = Bit.Vector(capacity: capacity)
            #expect(bits.capacity == capacity)
            #expect(bits.isEmpty == true)

            bits[0] = true
            bits[42] = true
            bits[99] = true

            #expect(bits[0] == true)
            #expect(bits[1] == false)
            #expect(bits[42] == true)
            #expect(bits[99] == true)

            let expectedPopcount: Bit.Index.Count = 3
            #expect(bits.popcount == expectedPopcount)
        }

        @Test
        func `Clear all bits`() {
            let capacity: Bit.Index.Count = 128
            var bits = Bit.Vector(capacity: capacity)

            bits[0] = true
            bits[64] = true
            bits[127] = true

            let expectedPopcount: Bit.Index.Count = 3
            #expect(bits.popcount == expectedPopcount)

            bits.clear.all()
            #expect(bits.isEmpty == true)
            #expect(bits.popcount == .zero)
        }

        @Test
        func `Set all bits`() {
            let capacity: Bit.Index.Count = 100
            var bits = Bit.Vector(capacity: capacity)
            bits.set.all()
            #expect(bits.popcount == capacity)
            #expect(bits.isFull == true)
        }

        @Test
        func `Iterate set bits`() {
            let capacity: Bit.Index.Count = 200
            let bits = Bit.Vector(capacity: capacity)

            bits[5] = true
            bits[100] = true
            bits[150] = true

            var visited: [Bit.Index] = []
            bits.ones.forEach { visited.append($0) }

            #expect(visited.count == 3)
            let expected0: Bit.Index = 5
            let expected1: Bit.Index = 100
            let expected2: Bit.Index = 150
            #expect(visited[0] == expected0)
            #expect(visited[1] == expected1)
            #expect(visited[2] == expected2)
        }

        @Test
        func `Iterate clear bits`() {
            let capacity: Bit.Index.Count = 10
            let bits = Bit.Vector(capacity: capacity)

            bits[2] = true
            bits[7] = true

            var visited: [Bit.Index] = []
            bits.zeros.forEach { visited.append($0) }

            #expect(visited.count == 8)
            let expected0: Bit.Index = 0
            let expected1: Bit.Index = 1
            #expect(visited[0] == expected0)
            #expect(visited[1] == expected1)
        }

        // Chained-form regression for the reopened #3 corrective: calling
        // `iterableMakeIterator()` directly on the temporary `.ones` view
        // (never binding the view to a local) must hold for the vector's
        // whole lifetime under `@_lifetime(copy self)`. Under the prior
        // `@_lifetime(borrow self)` spelling this rejected with "lifetime-
        // dependent variable 'm' escapes its scope / it depends on the
        // lifetime of this parent value" — the dependency bound to the
        // ephemeral `.ones` temporary rather than forwarding through to what
        // the view already depends on (the vector). Verified against the real
        // package: this compiles clean under `copy self`.
        @Test
        func `Chained iterableMakeIterator holds across the vector's lifetime`() {
            let capacity: Bit.Index.Count = 16
            var bits = Bit.Vector(capacity: capacity)
            bits[3] = true
            bits[9] = true

            var m = bits.ones.iterableMakeIterator()
            var visited: [Bit.Index] = []
            while true {
                let span = m.next(maximumCount: Cardinal(UInt.max))
                if span.isEmpty { break }
                for index in span.indices {
                    visited.append(span[index])
                }
            }

            #expect(visited.count == 2)
            let expected0: Bit.Index = 3
            let expected1: Bit.Index = 9
            #expect(visited[0] == expected0)
            #expect(visited[1] == expected1)
        }
    }
}

// MARK: - #4: subscript bounds safety
//
// swift-primitives/swift-bit-vector-primitives#4 — the subscript performed no
// bounds check while `toggle(_:)` did. Per the coordinator's ruled posture
// (issue comment 5140090959, 2026-07-31): the subscript now adopts the same
// checked posture `toggle(_:)` already has, and the declared `@safe` absorber
// claim at the type's declaration stands unchanged.
//
// The out-of-bounds cases fork a child process (Swift Testing exit tests) so
// the trap cannot bring down the parent test run; per the swift-span-primitives
// `Span.Raw.Mutable+"Bounds Safety"` precedent this suite is `.serialized` to
// avoid interleaving forks with concurrently running sibling tests.
extension Bit.Vector {
    @Suite(.serialized) struct `Bounds Safety` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension Bit.Vector.`Bounds Safety`.Unit {
    @Test
    func `subscript get at the last valid index does not trap`() {
        let bits = Bit.Vector(capacity: 8)
        #expect(bits[7] == false)
    }

    @Test
    func `subscript set at the last valid index does not trap`() {
        let bits = Bit.Vector(capacity: 8)
        bits[7] = true
        #expect(bits[7] == true)
    }
}

extension Bit.Vector.`Bounds Safety`.`Edge Case` {
    @Test
    func `subscript get traps when index is out of bounds`() async {
        await #expect(processExitsWith: .failure) {
            let bits = Bit.Vector(capacity: 8)
            _ = bits[8]
        }
    }

    @Test
    func `subscript set traps when index is out of bounds`() async {
        await #expect(processExitsWith: .failure) {
            let bits = Bit.Vector(capacity: 8)
            bits[8] = true
        }
    }
}

@Suite struct `Bit.Vector.Static Tests` {
    @Test
    func `Static capacity`() {
        var bits = Bit.Vector.Static<2>()
        let expectedCapacity: Bit.Index.Count = 128
        #expect(Bit.Vector.Static<2>.capacity == expectedCapacity)
        #expect(bits.isEmpty == true)

        bits[0] = true
        bits[127] = true

        let expectedPopcount: Bit.Index.Count = 2
        #expect(bits.popcount == expectedPopcount)
    }

    @Test
    func `Static is copyable`() {
        var original = Bit.Vector.Static<1>()

        original[0] = true
        original[63] = true

        let copy = original
        #expect(copy[0] == true)
        #expect(copy[63] == true)

        // Modify original, copy unchanged
        original[0] = false
        #expect(original[0] == false)
        #expect(copy[0] == true)
    }

    @Test
    func `set.range single word`() {
        var bits = Bit.Vector.Static<4>()
        let lower: Bit.Index = 3
        let upper: Bit.Index = 7
        bits.set.range(lower..<upper)

        #expect(bits[2] == false)
        #expect(bits[3] == true)
        #expect(bits[4] == true)
        #expect(bits[5] == true)
        #expect(bits[6] == true)
        #expect(bits[7] == false)

        let expectedPopcount: Bit.Index.Count = 4
        #expect(bits.popcount == expectedPopcount)
    }

    @Test
    func `set.range multi word`() {
        var bits = Bit.Vector.Static<4>()
        let lower: Bit.Index = 60
        let upper: Bit.Index = 130
        bits.set.range(lower..<upper)

        #expect(bits[59] == false)
        #expect(bits[60] == true)
        #expect(bits[64] == true)
        #expect(bits[100] == true)
        #expect(bits[129] == true)
        #expect(bits[130] == false)

        let expectedPopcount: Bit.Index.Count = 70
        #expect(bits.popcount == expectedPopcount)
    }

    @Test
    func `set.range empty range`() {
        var bits = Bit.Vector.Static<4>()
        let lower: Bit.Index = 5
        bits.set.range(lower..<lower)
        #expect(bits.isEmpty == true)
    }

    @Test
    func `set.range full word boundary`() {
        var bits = Bit.Vector.Static<4>()
        let lower: Bit.Index = 0
        let upper: Bit.Index = 64
        bits.set.range(lower..<upper)

        let expectedPopcount: Bit.Index.Count = 64
        #expect(bits.popcount == expectedPopcount)
        #expect(bits[0] == true)
        #expect(bits[63] == true)
        #expect(bits[64] == false)
    }

    @Test
    func `clear.range single word`() {
        var bits = Bit.Vector.Static<4>()
        bits.set.all()

        let lower: Bit.Index = 10
        let upper: Bit.Index = 20
        bits.clear.range(lower..<upper)

        #expect(bits[9] == true)
        #expect(bits[10] == false)
        #expect(bits[19] == false)
        #expect(bits[20] == true)

        let expectedPopcount: Bit.Index.Count = 246
        #expect(bits.popcount == expectedPopcount)
    }

    @Test
    func `clear.range multi word`() {
        var bits = Bit.Vector.Static<4>()
        bits.set.all()

        let lower: Bit.Index = 60
        let upper: Bit.Index = 130
        bits.clear.range(lower..<upper)

        #expect(bits[59] == true)
        #expect(bits[60] == false)
        #expect(bits[100] == false)
        #expect(bits[129] == false)
        #expect(bits[130] == true)

        let expectedPopcount: Bit.Index.Count = 186
        #expect(bits.popcount == expectedPopcount)
    }

    @Test
    func `set.range then clear.range roundtrip`() {
        var bits = Bit.Vector.Static<4>()
        let lower: Bit.Index = 0
        let upper: Bit.Index = 100
        bits.set.range(lower..<upper)

        let expectedPopcount: Bit.Index.Count = 100
        #expect(bits.popcount == expectedPopcount)

        bits.clear.range(lower..<upper)
        #expect(bits.isEmpty == true)
    }

    @Test
    func `set.range single bit`() {
        var bits = Bit.Vector.Static<4>()
        let lower: Bit.Index = 42
        let upper: Bit.Index = 43
        bits.set.range(lower..<upper)

        #expect(bits[41] == false)
        #expect(bits[42] == true)
        #expect(bits[43] == false)

        let expectedPopcount: Bit.Index.Count = 1
        #expect(bits.popcount == expectedPopcount)
    }

    @Test
    func `set.range preserves existing bits`() {
        var bits = Bit.Vector.Static<4>()
        bits[0] = true
        bits[200] = true

        let lower: Bit.Index = 10
        let upper: Bit.Index = 20
        bits.set.range(lower..<upper)

        #expect(bits[0] == true)
        #expect(bits[200] == true)

        let expectedPopcount: Bit.Index.Count = 12
        #expect(bits.popcount == expectedPopcount)
    }
}
