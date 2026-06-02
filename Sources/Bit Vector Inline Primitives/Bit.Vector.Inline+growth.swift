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

// MARK: - Append and Remove

extension Bit.Vector.Inline {
    /// Appends a boolean value.
    ///
    /// - Throws: `Error.overflow` if at capacity.
    @inlinable
    public mutating func append(_ value: Bool) throws(Bit.Vector.Inline.Error) {
        guard _count < Self._capacity else {
            throw .overflow
        }
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
        if value {
            _storage[loc.word] |= loc.mask
        }
        _count += .one
    }

    /// Appends a `Bit` value.
    ///
    /// - Throws: `Error.overflow` if at capacity.
    @inlinable
    public mutating func append(_ bit: Bit) throws(Bit.Vector.Inline.Error) {
        try append(Bool(bit))
    }

    /// Removes and returns the last element, or `nil` if empty.
    @discardableResult
    @inlinable
    public mutating func popLast() -> Bool? {
        guard _count > .zero else { return nil }
        _count = _count.subtract.saturating(.one)
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
        let value = (_storage[loc.word] & loc.mask) != 0
        _storage[loc.word] &= ~loc.mask
        return value
    }

    /// Removes the last element.
    @inlinable
    public mutating func removeLast() {
        precondition(_count > .zero, "Cannot remove from empty vector")
        _count = _count.subtract.saturating(.one)
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
        _storage[loc.word] &= ~loc.mask
    }

    /// Removes all elements.
    @inlinable
    public mutating func removeAll() {
        for i in 0..<wordCount {
            _storage[i] = 0
        }
        _count = .zero
    }
}
