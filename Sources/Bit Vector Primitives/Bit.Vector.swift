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

public import Bit_Primitives

// MARK: - Bit.Vector

extension Bit {
    /// Fixed-capacity packed bit storage using word-sized backing.
    ///
    /// `Bit.Vector` is the primitive storage type for dense bit representation.
    /// It packs bits into `UInt` words, providing O(1) indexed access with
    /// ~1 bit per element space efficiency.
    ///
    /// ## Design
    ///
    /// - Backing storage: `UnsafeMutablePointer<UInt>`
    /// - Bit-packed: 64 bits per word on 64-bit platforms
    /// - O(1) get/set by index
    /// - ~Copyable for ownership semantics
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var bits = Bit.Vector(capacity: Bit.Index.Count(100))
    /// bits[Bit.Index(42)] = true
    /// if bits[Bit.Index(42)] { ... }
    /// ```
    ///
    /// ## Variants
    ///
    /// - ``Bit.Vector``: Fixed-capacity, ~Copyable infrastructure bitmap (this type)
    /// - ``Bit.Vector.Static``: Fixed-capacity inline bitmap (Copyable, no count tracking)
    /// - ``Bit.Vector.Dynamic``: Growable packed bit array (Copyable, heap-allocated)
    /// - ``Bit.Vector.Bounded``: Fixed-capacity packed bit array (Copyable, heap-allocated)
    /// - ``Bit.Vector.Inline``: Fixed-capacity inline bit array (Copyable, stack-allocated)
    @safe
    public struct Vector: ~Copyable {
        @usableFromInline
        package var _words: UnsafeMutablePointer<UInt>

        /// Word count.
        @usableFromInline
        package let _wordCount: Index_Primitives.Index<UInt>.Count

        /// The capacity in bits.
        public let capacity: Bit.Index.Count

        /// Creates a bit vector with the specified capacity.
        ///
        /// All bits are initially cleared (false).
        ///
        /// - Parameter capacity: The number of bits to track.
        @inlinable
        public init(capacity: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)

            self._wordCount = pack.words.count
            self.capacity = capacity

            if _wordCount > .zero {
                unsafe self._words = .allocate(capacity: _wordCount)
                unsafe _words.initialize(repeating: 0, count: _wordCount)
            } else {
                unsafe self._words = .init(bitPattern: 0x1)!  // Non-null sentinel for empty
            }
        }

        deinit {
            if _wordCount > .zero {
                unsafe _words.deallocate()
            }
        }
    }
}

// MARK: - Subscript Access

extension Bit.Vector {
    /// Gets or sets the bit at the specified index.
    ///
    /// - Parameter index: The bit index. Must be in `0..<capacity`.
    /// - Returns: `true` if the bit is set, `false` otherwise.
    @inlinable
    public subscript(index: Bit.Index) -> Bool {
        get {
            let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
            return unsafe (_words[location.word] & location.mask) != 0
        }
        nonmutating set {
            let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
            let current = unsafe _words[location.word]
            if newValue {
                unsafe _words[location.word] = current | location.mask
            } else {
                unsafe _words[location.word] = current & ~location.mask
            }
        }
    }
}

// MARK: - Bulk Operations

extension Bit.Vector {
    /// Whether all bits are false.
    @inlinable
    public var isEmpty: Bool { allFalse }

    /// Whether all bits are true.
    @inlinable
    public var isFull: Bool { allTrue }
}

// MARK: - Word Access

extension Bit.Vector {
    /// Direct access to the underlying word storage.
    ///
    /// - Parameter body: A closure that receives a buffer pointer to the words.
    /// - Returns: The value returned by the closure.
    @inlinable
    public func withUnsafeWords<R>(_ body: (UnsafeBufferPointer<UInt>) -> R) -> R {
        return unsafe body(UnsafeBufferPointer(start: _words, count: _wordCount))
    }

    /// Mutable access to the underlying word storage.
    ///
    /// - Parameter body: A closure that receives a mutable buffer pointer to the words.
    /// - Returns: The value returned by the closure.
    @inlinable
    public func withUnsafeMutableWords<R>(_ body: (UnsafeMutableBufferPointer<UInt>) -> R) -> R {
        return unsafe body(UnsafeMutableBufferPointer(start: _words, count: _wordCount))
    }
}

// MARK: - Sendable

extension Bit.Vector: @unchecked Sendable {}
