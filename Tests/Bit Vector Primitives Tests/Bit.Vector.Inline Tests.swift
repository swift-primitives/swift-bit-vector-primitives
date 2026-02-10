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

enum BitVectorInlineTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension BitVectorInlineTests.Unit {
    @Test("Create empty")
    func createEmpty() {
        let bits = Bit.Vector.Inline<2>()
        #expect(bits.isEmpty)
        #expect(bits.count == 0)
        #expect(!bits.isFull)
    }

    @Test("Append and subscript")
    func appendAndSubscript() throws {
        var bits = Bit.Vector.Inline<1>()

        try bits.append(true)
        try bits.append(false)
        try bits.append(true)

        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[2] == true)
        #expect(bits.count == 3)
    }

    @Test("Overflow throws")
    func overflowThrows() throws {
        var bits = Bit.Vector.Inline<1>()
        for _ in 0..<64 {
            try bits.append(true)
        }
        #expect(bits.isFull)

        #expect(throws: __BitVectorInlineError.overflow) {
            try bits.append(true)
        }
    }

    @Test("popLast")
    func popLast() throws {
        var bits = Bit.Vector.Inline<1>()
        try bits.append(true)
        try bits.append(false)

        let last = bits.popLast()
        #expect(last == false)
        #expect(bits.count == 1)

        let first = bits.popLast()
        #expect(first == true)
        #expect(bits.isEmpty)

        #expect(bits.popLast() == nil)
    }

    @Test("set and clear")
    func setAndClear() throws {
        var bits = try Bit.Vector.Inline<1>(count: 10)

        try bits.set(5)
        #expect(bits[5] == true)

        try bits.clear(5)
        #expect(bits[5] == false)
    }

    @Test("toggle")
    func toggle() throws {
        var bits = try Bit.Vector.Inline<1>(count: 10)

        try bits.toggle(3)
        #expect(bits[3] == true)

        try bits.toggle(3)
        #expect(bits[3] == false)
    }

    @Test("statistic.true and statistic.false")
    func statistics() throws {
        var bits = try Bit.Vector.Inline<1>(count: 5)
        try bits.set(0)
        try bits.set(2)
        try bits.set(4)

        #expect(bits.statistic.true == 3)
        #expect(bits.statistic.false == 2)
    }

    @Test("capacity.maximum and capacity.remaining")
    func capacity() throws {
        var bits = Bit.Vector.Inline<2>()
        try bits.append(true)
        try bits.append(false)

        #expect(bits.capacity.maximum == 128)
        #expect(bits.capacity.remaining == 126)
    }

    @Test("Iteration")
    func iteration() throws {
        var bits = Bit.Vector.Inline<1>()
        try bits.append(true)
        try bits.append(false)
        try bits.append(true)

        var values: [Bool] = []
        for bit in bits {
            values.append(bit)
        }

        #expect(values == [true, false, true])
    }

    @Test("Equality")
    func equality() throws {
        var a = Bit.Vector.Inline<1>()
        var b = Bit.Vector.Inline<1>()

        try a.append(true)
        try a.append(false)

        try b.append(true)
        try b.append(false)

        #expect(a == b)

        try b.append(true)
        #expect(a != b)
    }

    @Test("Description")
    func description() throws {
        var bits = Bit.Vector.Inline<1>()
        try bits.append(true)
        try bits.append(false)

        let desc = bits.description
        #expect(desc.contains("Bit.Vector.Inline<1>"))
        #expect(desc.contains("10"))
    }

    @Test("Init with count")
    func initWithCount() throws {
        let bits = try Bit.Vector.Inline<2>(count: 100)
        #expect(bits.count == 100)
        #expect(bits.popcount == 0)
    }

    @Test("Init repeating true")
    func initRepeatingTrue() throws {
        let bits = try Bit.Vector.Inline<1>(repeating: true, count: 10)
        #expect(bits.count == 10)
        #expect(bits.popcount == 10)
    }

    @Test("Init repeating false")
    func initRepeatingFalse() throws {
        let bits = try Bit.Vector.Inline<1>(repeating: false, count: 10)
        #expect(bits.count == 10)
        #expect(bits.popcount == 0)
    }
}

// MARK: - Edge Cases

extension BitVectorInlineTests.EdgeCase {
    @Test("Word boundary")
    func wordBoundary() throws {
        var bits = try Bit.Vector.Inline<2>(count: 100)

        bits[63] = true
        bits[64] = true

        #expect(bits[63] == true)
        #expect(bits[64] == true)
        #expect(bits[62] == false)
        #expect(bits[65] == false)
    }

    @Test("Bounds error")
    func boundsError() throws {
        var bits = try Bit.Vector.Inline<1>(count: 5)

        #expect(throws: __BitVectorInlineError.self) {
            try bits.set(10)
        }
    }

    @Test("Conversion to Dynamic")
    func conversionToDynamic() throws {
        var inline = Bit.Vector.Inline<1>()
        try inline.append(true)
        try inline.append(false)
        try inline.append(true)

        let dynamic = Bit.Vector.Dynamic(inline)
        #expect(dynamic.count == 3)
        #expect(dynamic[0] == true)
        #expect(dynamic[1] == false)
        #expect(dynamic[2] == true)
    }
}
