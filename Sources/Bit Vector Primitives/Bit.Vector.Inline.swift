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

// MARK: - Bit.Vector.Inline

extension Bit.Vector {
    /// Zero-allocation packed bit array with compile-time capacity.
    ///
    /// `Bit.Vector.Inline` stores bits in inline storage using `InlineArray`,
    /// avoiding heap allocation entirely. The capacity is specified as a compile-time
    /// constant representing the number of `UInt` words.
    ///
    /// Unlike `Bit.Vector.Static<N>` (which always uses full capacity as a pure bitmap),
    /// `Inline<N>` has variable count with bounded capacity — it's a container.
    ///
    /// ```swift
    /// // 2 words = 128 bits on 64-bit systems
    /// var bits = Bit.Vector.Inline<2>()
    /// try bits.append(true)
    /// try bits.append(false)
    /// bits[Bit.Index(0)]  // true
    /// ```
    public struct Inline<let wordCount: Int>: Sendable {
        /// The maximum number of bits that can be stored.
        @inlinable
        public static var _capacity: Bit.Index.Count {
            Bit.Index.Count(Cardinal(UInt(wordCount * UInt.bitWidth)))
        }

        @usableFromInline
        var _storage: InlineArray<wordCount, UInt>

        @usableFromInline
        var _count: Bit.Index.Count

        /// Creates an empty inline bit vector.
        @inlinable
        public init() {
            self._storage = InlineArray(repeating: 0)
            self._count = .zero
        }

        /// Creates an inline bit vector with an initial count.
        ///
        /// - Throws: `Error.overflow` if count exceeds capacity.
        @inlinable
        public init(count: Bit.Index.Count) throws(Error) {
            guard count <= Self._capacity else {
                throw .overflow
            }
            self._storage = InlineArray(repeating: 0)
            self._count = count
        }

        /// Creates an inline bit vector with a repeated value.
        ///
        /// - Throws: `Error.overflow` if count exceeds capacity.
        @inlinable
        public init(repeating value: Bool, count: Bit.Index.Count) throws(Error) {
            guard count <= Self._capacity else {
                throw .overflow
            }
            self._storage = InlineArray(repeating: value ? ~0 : 0)
            self._count = count

            if value && count > .zero {
                let pack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
                if pack.bits.unused > .zero {
                    let lastWordIndex = try! pack.words.count.map(Ordinal.init).predecessor.exact()
                    let mask: UInt = ~0 >> pack.bits.unused
                    _storage[lastWordIndex] = mask
                }
                // Clear words beyond count
                let countWords = Int(bitPattern: pack.words.count)
                for i in countWords..<wordCount {
                    _storage[i] = 0
                }
            }
        }

        /// Errors that can occur during operations.
        public typealias Error = __BitVectorInlineError
    }
}

// MARK: - Properties

extension Bit.Vector.Inline {
    /// The number of bits.
    @inlinable
    public var count: Bit.Index.Count { _count }

    /// Whether the vector contains no bits.
    @inlinable
    public var isEmpty: Bool { _count == .zero }

    /// Whether the vector is at full capacity.
    @inlinable
    public var isFull: Bool { _count >= Self._capacity }

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

extension Bit.Vector.Inline {
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
