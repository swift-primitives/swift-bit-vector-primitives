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

extension Bit.Vector.Dynamic {
    /// Appends a boolean value.
    @inlinable
    public mutating func append(_ value: Bool) {
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)

        if Int(bitPattern: loc.word) >= _storage.count {
            _storage.append(0)
        }

        if value {
            _storage[loc.word] |= loc.mask
        }

        _count = _count + .one
    }

    /// Appends a `Bit` value.
    @inlinable
    public mutating func append(_ bit: Bit) {
        append(Bool(bit))
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
    public mutating func removeAll(keepingCapacity: Bool = false) {
        if keepingCapacity {
            for i in 0..<_storage.count {
                _storage[i] = 0
            }
        } else {
            _storage.removeAll()
        }
        _count = .zero
    }
}

// MARK: - Resize

extension Bit.Vector.Dynamic {
    /// Resizes the vector to the given count.
    ///
    /// New bits are initialized to `fill` (default: false).
    @inlinable
    public mutating func resize(to newCount: Bit.Index.Count, fill: Bool = false) {
        let newPack = Bit.Pack<UInt>(count: newCount, bitsPerWord: .bitsPerWord)
        let oldWordCount = _storage.count
        let newWordCount = Int(bitPattern: newPack.words.count)

        if newWordCount > oldWordCount {
            let fillValue: UInt = fill ? ~0 : 0
            _storage.reserveCapacity(newWordCount)
            for _ in oldWordCount..<newWordCount {
                _storage.append(fillValue)
            }
        } else if newWordCount < oldWordCount {
            _storage.removeLast(oldWordCount - newWordCount)
        }

        if fill && newCount > _count && oldWordCount > 0 {
            let oldLoc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
            if oldLoc.bit > .zero && oldLoc.word < newPack.words.count {
                let highMask: UInt = ~0 << Int(bitPattern: oldLoc.bit)
                _storage[oldLoc.word] |= highMask
            }
        }

        _count = newCount

        if newWordCount > 0 && newPack.bits.unused > .zero {
            let lastWord = newWordCount - 1
            let mask: UInt = ~0 >> Int(bitPattern: newPack.bits.unused)
            _storage[lastWord] &= mask
        }
    }
}
