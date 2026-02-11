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

import Affine_Primitives

// MARK: - Bit Operations

extension Bit.Vector.Bounded {
    /// Sets the bit at the given index to true.
    @inlinable
    public mutating func set(_ index: Bit.Index) throws(Error) {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        _storage[loc.word] |= loc.mask
    }

    /// Clears the bit at the given index to false.
    @inlinable
    public mutating func clear(_ index: Bit.Index) throws(Error) {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        _storage[loc.word] &= ~loc.mask
    }

    /// Toggles the bit at the given index.
    @inlinable
    public mutating func toggle(_ index: Bit.Index) throws(Error) {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        _storage[loc.word] ^= loc.mask
    }

    /// Clears all bits to false.
    @inlinable
    public mutating func clearAll() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }

    /// Sets all bits (up to count) to true.
    @inlinable
    public mutating func setAll() {
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        var w: Index<UInt> = .zero
        while w < end {
            _storage[w] = ~0
            w += .one
        }
        if pack.bits.unused > .zero && pack.words.count > .zero {
            let lastWord = try! end.predecessor.exact()
            let mask: UInt = ~0 >> pack.bits.unused
            _storage[lastWord] = mask
        }
    }
}
