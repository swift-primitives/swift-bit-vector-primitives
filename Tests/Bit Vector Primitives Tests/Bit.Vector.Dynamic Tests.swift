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

enum BitVectorDynamicTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension BitVectorDynamicTests.Unit {
    @Test
    func `Append and subscript`() {
        var bits = Bit.Vector.Dynamic()

        bits.append(true)
        bits.append(false)
        bits.append(true)

        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[2] == true)
        #expect(bits.count == 3)
    }

    @Test
    func `Subscript set`() {
        var bits = Bit.Vector.Dynamic([true, true, true])

        bits[1] = false

        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[2] == true)
    }

    @Test
    func `popLast`() {
        var bits = Bit.Vector.Dynamic([true, false, true])

        let last = bits.popLast()
        #expect(last == true)
        #expect(bits.count == 2)

        let second = bits.popLast()
        #expect(second == false)
        #expect(bits.count == 1)

        let first = bits.popLast()
        #expect(first == true)
        #expect(bits.isEmpty)

        let empty = bits.popLast()
        #expect(empty == nil)
    }

    @Test
    func `removeLast`() {
        var bits = Bit.Vector.Dynamic([true, false])

        bits.removeLast()
        #expect(bits.count == 1)
        #expect(bits[0] == true)
    }

    @Test
    func `removeAll`() {
        var bits = Bit.Vector.Dynamic([true, false, true])

        bits.removeAll()
        #expect(bits.isEmpty)
    }

    @Test
    func `count and isEmpty`() {
        var bits = Bit.Vector.Dynamic()
        #expect(bits.isEmpty)

        bits.append(true)
        #expect(bits.count == 1)
        #expect(!bits.isEmpty)
    }

    @Test
    func `first and last`() {
        var bits = Bit.Vector.Dynamic()
        #expect(bits.first == nil)
        #expect(bits.last == nil)

        bits.append(true)
        #expect(bits.first == true)
        #expect(bits.last == true)

        bits.append(false)
        #expect(bits.first == true)
        #expect(bits.last == false)
    }

    @Test
    func `Init from Bool sequence`() {
        let bits = Bit.Vector.Dynamic([true, false, true, false])

        #expect(bits.count == 4)
        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[2] == true)
        #expect(bits[3] == false)
    }

    @Test
    func `Init repeating true`() {
        let bits = Bit.Vector.Dynamic(repeating: true, count: 5)

        #expect(bits.count == 5)
        for n in 0..<5 {
            let i: Bit.Index = Bit.Index(integerLiteral: UInt(n))
            #expect(bits[i] == true)
        }
    }

    @Test
    func `Init repeating false`() {
        let bits = Bit.Vector.Dynamic(repeating: false, count: 5)

        #expect(bits.count == 5)
        for n in 0..<5 {
            let i: Bit.Index = Bit.Index(integerLiteral: UInt(n))
            #expect(bits[i] == false)
        }
    }

    @Test
    func `toggle`() throws {
        var bits = Bit.Vector.Dynamic([true, false, true])

        try bits.toggle(0)
        try bits.toggle(1)
        try bits.toggle(2)

        #expect(bits[0] == false)
        #expect(bits[1] == true)
        #expect(bits[2] == false)
    }

    @Test
    func `statistic.true and statistic.false`() {
        let bits = Bit.Vector.Dynamic([true, false, true, false, true])

        #expect(bits.statistic.true == 3)
        #expect(bits.statistic.false == 2)
    }

    @Test
    func `all.true and all.false`() {
        let allTrue = Bit.Vector.Dynamic([true, true, true])
        let allFalse = Bit.Vector.Dynamic([false, false, false])
        let mixed = Bit.Vector.Dynamic([true, false, true])

        #expect(allTrue.all.true)
        #expect(!allTrue.all.false)

        #expect(!allFalse.all.true)
        #expect(allFalse.all.false)

        #expect(!mixed.all.true)
        #expect(!mixed.all.false)
    }

    @Test
    func `Iteration`() {
        let bits = Bit.Vector.Dynamic([true, false, true, false])

        var values: [Bool] = []
        for bit in bits {
            values.append(bit)
        }

        #expect(values == [true, false, true, false])
    }

    @Test
    func `Equality`() {
        let a = Bit.Vector.Dynamic([true, false, true])
        let b = Bit.Vector.Dynamic([true, false, true])
        let c = Bit.Vector.Dynamic([true, true, true])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Description`() {
        let bits = Bit.Vector.Dynamic([true, false, true])
        let desc = bits.description
        #expect(desc.contains("Bit.Vector.Dynamic"))
        #expect(desc.contains("101"))
    }

    @Test
    func `Append Bit type`() {
        var bits = Bit.Vector.Dynamic()
        bits.append(Bit.one)
        bits.append(Bit.zero)
        bits.append(Bit.one)

        #expect(bits.count == 3)
        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[2] == true)
    }

    @Test
    func `Resize grow`() {
        var bits = Bit.Vector.Dynamic([true, false])
        bits.resize(to: 5, fill: true)

        #expect(bits.count == 5)
        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[2] == true)
        #expect(bits[3] == true)
        #expect(bits[4] == true)
    }

    @Test
    func `Resize shrink`() {
        var bits = Bit.Vector.Dynamic([true, false, true, false, true])
        bits.resize(to: 2)

        #expect(bits.count == 2)
        #expect(bits[0] == true)
        #expect(bits[1] == false)
    }
}

// MARK: - Edge Cases

extension BitVectorDynamicTests.EdgeCase {
    @Test
    func `Empty arrays equal`() {
        let a = Bit.Vector.Dynamic()
        let b = Bit.Vector.Dynamic()
        #expect(a == b)
    }

    @Test
    func `Different lengths not equal`() {
        let a = Bit.Vector.Dynamic([true, false])
        let b = Bit.Vector.Dynamic([true, false, true])
        #expect(a != b)
    }

    @Test
    func `Word boundary: index 63 and 64`() {
        var bits = Bit.Vector.Dynamic(repeating: false, count: 100)

        bits[63] = true
        bits[64] = true

        #expect(bits[63] == true)
        #expect(bits[64] == true)
        #expect(bits[62] == false)
        #expect(bits[65] == false)
    }

    @Test
    func `Large array`() {
        var bits = Bit.Vector.Dynamic(repeating: false, count: 1000)

        bits[0] = true
        bits[500] = true
        bits[999] = true

        #expect(bits.count == 1000)
        #expect(bits.popcount == 3)
    }
}
