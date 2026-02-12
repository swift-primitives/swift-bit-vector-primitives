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

// MARK: - Bit.Vector.Inline: Bit.Vector.Protocol

extension Bit.Vector.Inline: Bit.Vector.`Protocol` {
    @inlinable
    public var bitCapacity: Bit.Index.Count { Self._capacity }

    @inlinable
    public borrowing func word(at index: Int) -> UInt {
        _storage[index]
    }

    @inlinable
    public mutating func setWord(at index: Int, to value: UInt) {
        _storage[index] = value
    }

    // subscript(index: Bit.Index) -> Bool { get set } — already provided
}
