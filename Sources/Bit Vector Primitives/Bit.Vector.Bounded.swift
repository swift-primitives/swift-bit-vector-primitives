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

// MARK: - Bit.Vector.Bounded

extension Bit.Vector {
    /// Fixed-capacity packed bit array.
    ///
    /// `Bit.Vector.Bounded` stores bits packed into `UInt` words with a fixed
    /// maximum capacity. Append operations throw on overflow.
    ///
    /// ```swift
    /// var bits = Bit.Vector.Bounded(capacity: Bit.Index.Count(100))
    /// try bits.append(true)
    /// try bits.set(Bit.Index(50))
    /// bits[Bit.Index(50)]  // true
    /// ```
    public struct Bounded: Sendable {
        @usableFromInline
        let _capacity: Bit.Index.Count

        @usableFromInline
        var _storage: ContiguousArray<UInt>

        @usableFromInline
        var _count: Bit.Index.Count

        /// Creates an empty bounded bit vector with the specified capacity.
        @inlinable
        public init(capacity: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)
            self._capacity = capacity
            self._storage = ContiguousArray(repeating: 0, count: pack.words.count)
            self._count = .zero
        }

        /// Creates a bounded bit vector with an initial count.
        ///
        /// - Throws: `Error.overflow` if count exceeds capacity.
        @inlinable
        public init(capacity: Bit.Index.Count, count: Bit.Index.Count) throws(Error) {
            guard count <= capacity else {
                throw .overflow
            }
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)
            self._capacity = capacity
            self._storage = ContiguousArray(repeating: 0, count: pack.words.count)
            self._count = count
        }

        /// Creates a bounded bit vector from a sequence.
        ///
        /// - Throws: `Error.overflow` if the sequence exceeds capacity.
        @inlinable
        public init<S: Swift.Sequence>(capacity: Bit.Index.Count, _ elements: S) throws(Error) where S.Element == Bool {
            self.init(capacity: capacity)
            for element in elements {
                try append(element)
            }
        }

        /// Creates a bounded bit vector with a repeated value.
        ///
        /// - Throws: `Error.overflow` if count exceeds capacity.
        @inlinable
        public init(capacity: Bit.Index.Count, repeating value: Bool, count: Bit.Index.Count) throws(Error) {
            guard count <= capacity else {
                throw .overflow
            }
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)
            self._capacity = capacity
            self._storage = ContiguousArray(repeating: value ? ~0 : 0, count: pack.words.count)
            self._count = count

            if value && count > .zero {
                let countPack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
                if countPack.bits.unused > .zero {
                    let lastWord = try! countPack.words.count.map(Ordinal.init).predecessor.exact()
                    let mask: UInt = ~0 >> countPack.bits.unused
                    _storage[lastWord] = mask
                }
                // Clear words beyond count
                let countWords = Int(bitPattern: countPack.words.count)
                for i in countWords..<_storage.count {
                    _storage[i] = 0
                }
            }
        }

        /// Errors that can occur during operations.
        public typealias Error = __BitVectorBoundedError
    }
}

// MARK: - Properties

extension Bit.Vector.Bounded {
    /// The number of bits.
    @inlinable
    public var count: Bit.Index.Count { _count }

    /// Whether the vector contains no bits.
    @inlinable
    public var isEmpty: Bool { _count == .zero }

    /// Whether the vector is at full capacity.
    @inlinable
    public var isFull: Bool { _count >= _capacity }

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
}

// MARK: - Subscript Access

extension Bit.Vector.Bounded {
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
