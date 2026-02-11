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

extension Bit.Vector.Dynamic {
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

    /// Sets all bits to true.
    @inlinable
    public mutating func setAll() {
        for i in 0..<_storage.count {
            _storage[i] = ~0
        }
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        if pack.bits.unused > .zero && !_storage.isEmpty {
            let lastWord = _storage.count - 1
            let mask: UInt = ~0 >> pack.bits.unused
            _storage[lastWord] = mask
        }
    }
}
