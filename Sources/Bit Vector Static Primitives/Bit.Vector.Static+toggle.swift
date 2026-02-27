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

extension Bit.Vector.Static {
    /// Toggles the bit at the given index.
    ///
    /// - Precondition: `index < capacity`.
    @inlinable
    public mutating func toggle(_ index: Bit.Index) {
        precondition(index < Self.capacity, "Index out of bounds")
        let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
        _storage[location.word] ^= location.mask
    }
}
