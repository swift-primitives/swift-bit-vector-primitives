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
