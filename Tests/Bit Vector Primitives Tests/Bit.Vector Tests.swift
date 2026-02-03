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

import Testing
import Bit_Vector_Primitives
import Bit_Vector_Primitives_Test_Support

@Suite("Bit.Vector Tests")
struct BitVectorTests {
    @Test("Create empty vector")
    func createEmpty() {
        let bits = Bit.Vector(capacity: .zero)
        #expect(bits.capacity == .zero)
        #expect(bits.isEmpty == true)
        #expect(bits.popcount == .zero)
    }

    @Test("Create and access bits")
    func createAndAccess() {
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

    @Test("Clear all bits")
    func clearAll() {
        let capacity: Bit.Index.Count = 128
        let bits = Bit.Vector(capacity: capacity)

        bits[0] = true
        bits[64] = true
        bits[127] = true

        let expectedPopcount: Bit.Index.Count = 3
        #expect(bits.popcount == expectedPopcount)

        bits.clearAll()
        #expect(bits.isEmpty == true)
        #expect(bits.popcount == .zero)
    }

    @Test("Set all bits")
    func setAll() {
        let capacity: Bit.Index.Count = 100
        let bits = Bit.Vector(capacity: capacity)
        bits.setAll()
        #expect(bits.popcount == capacity)
        #expect(bits.isFull == true)
    }

    @Test("Iterate set bits")
    func iterateSetBits() {
        let capacity: Bit.Index.Count = 200
        let bits = Bit.Vector(capacity: capacity)

        bits[5] = true
        bits[100] = true
        bits[150] = true

        var visited: [Bit.Index] = []
        bits.forEachSetBit { visited.append($0) }

        #expect(visited.count == 3)
        let expected0: Bit.Index = 5
        let expected1: Bit.Index = 100
        let expected2: Bit.Index = 150
        #expect(visited[0] == expected0)
        #expect(visited[1] == expected1)
        #expect(visited[2] == expected2)
    }
}

@Suite("Bit.Vector.Static Tests")
struct BitVectorStaticTests {
    @Test("Static capacity")
    func staticCapacity() {
        var bits = Bit.Vector.Static<2>()
        let expectedCapacity: Bit.Index.Count = 128
        #expect(Bit.Vector.Static<2>.capacity == expectedCapacity)
        #expect(bits.isEmpty == true)

        bits[0] = true
        bits[127] = true

        let expectedPopcount: Bit.Index.Count = 2
        #expect(bits.popcount == expectedPopcount)
    }

    @Test("Static is copyable")
    func staticIsCopyable() {
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
}
