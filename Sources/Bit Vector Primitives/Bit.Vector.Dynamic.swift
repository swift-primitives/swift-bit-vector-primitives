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

// MARK: - Bit.Vector.Dynamic

extension Bit.Vector {
    /// Growable packed bit array using word-sized storage.
    ///
    /// `Bit.Vector.Dynamic` stores bits packed into `UInt` words, providing 8x space
    /// efficiency over `[Bool]`. Operations are O(1) for single bit access and O(n/64)
    /// for bulk operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var bits = Bit.Vector.Dynamic()
    /// bits.append(true)
    /// bits.append(false)
    /// bits[Bit.Index(0)]  // true
    /// bits.popcount       // 1
    /// ```
    ///
    /// ## Variants
    ///
    /// - ``Bit.Vector.Dynamic``: Dynamically-growing storage (this type)
    /// - ``Bit.Vector.Bounded``: Fixed-capacity, throws on overflow
    /// - ``Bit.Vector.Inline``: Zero-allocation inline storage with compile-time capacity
    public struct Dynamic: Sendable {
        @usableFromInline
        var _storage: ContiguousArray<UInt>

        @usableFromInline
        var _count: Bit.Index.Count

        /// Creates an empty bit vector.
        @inlinable
        public init() {
            self._storage = []
            self._count = .zero
        }

        /// Creates a bit vector with the given count, all bits cleared.
        @inlinable
        public init(count: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
            self._storage = ContiguousArray(repeating: 0, count: pack.words.count)
            self._count = count
        }

        /// Creates a bit vector with a repeated value.
        @inlinable
        public init(repeating value: Bool, count: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
            self._storage = ContiguousArray(repeating: value ? ~0 : 0, count: pack.words.count)
            self._count = count

            if value && count > .zero && pack.bits.unused > .zero {
                let lastWord = _storage.count - 1
                let mask: UInt = ~0 >> pack.bits.unused
                _storage[lastWord] = mask
            }
        }

        /// Creates a bit vector with a repeated `Bit` value.
        @inlinable
        public init(repeating bit: Bit, count: Bit.Index.Count) {
            self.init(repeating: Bool(bit), count: count)
        }

        /// Creates a bit vector from a sequence of booleans.
        @inlinable
        public init<S: Swift.Sequence>(_ elements: S) where S.Element == Bool {
            self.init()
            for element in elements {
                append(element)
            }
        }

        /// Creates a bit vector from a sequence of `Bit` values.
        @inlinable
        public init<S: Swift.Sequence>(_ elements: S) where S.Element == Bit {
            self.init()
            for element in elements {
                append(Bool(element))
            }
        }

        /// Errors that can occur during operations.
        public typealias Error = __BitVectorDynamicError
    }
}

// MARK: - Properties

extension Bit.Vector.Dynamic {
    /// The number of bits.
    @inlinable
    public var count: Bit.Index.Count { _count }

    /// Whether the vector contains no bits.
    @inlinable
    public var isEmpty: Bool { _count == .zero }

    /// The number of bits set to true.
    @inlinable
    public var popcount: Bit.Index.Count {
        var total: UInt = 0
        for word in _storage {
            total += UInt(word.nonzeroBitCount)
        }
        return Bit.Index.Count(Cardinal(total))
    }

    /// The first bit value, or `nil` if empty.
    @inlinable
    public var first: Bool? {
        guard _count > .zero else { return nil }
        return (_storage[0] & 1) != 0
    }

    /// The last bit value, or `nil` if empty.
    @inlinable
    public var last: Bool? {
        guard _count > .zero else { return nil }
        let lastIndex = _count.subtract.saturating(.one)
        let loc = Bit.Pack<UInt>.Location(count: lastIndex, bitsPerWord: .bitsPerWord)
        return (_storage[loc.word] & loc.mask) != 0
    }

    @usableFromInline
    var _wordCount: Int { _storage.count }
}

// MARK: - Subscript Access

extension Bit.Vector.Dynamic {
    /// Gets or sets the bit at the given index.
    @inlinable
    public subscript(index: Bit.Index) -> Bool {
        get {
            precondition(index < _count, "Index out of bounds")
            let loc = index.location(bitsPerWord: .bitsPerWord)
            return (_storage[loc.word] & loc.mask) != 0
        }
        set {
            precondition(index < _count, "Index out of bounds")
            let loc = index.location(bitsPerWord: .bitsPerWord)
            if newValue {
                _storage[loc.word] |= loc.mask
            } else {
                _storage[loc.word] &= ~loc.mask
            }
        }
    }

    /// Returns the bit at the given index, throwing on bounds violation.
    @inlinable
    public func get(_ index: Bit.Index) throws(Error) -> Bool {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        return (_storage[loc.word] & loc.mask) != 0
    }
}
