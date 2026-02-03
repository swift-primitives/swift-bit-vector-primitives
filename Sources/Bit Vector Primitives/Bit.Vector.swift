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
    /// ## Relationship to Set/Array
    ///
    /// For set semantics (membership, algebra), use `Set<Bit>.Vector`.
    /// For array semantics (count, append), use `Array<Bit>.Vector`.
    /// Those types wrap `Bit.Vector` with their respective semantics.
    @safe
    public struct Vector: ~Copyable {
        @usableFromInline
        package var _words: UnsafeMutablePointer<UInt>

        /// Word count — stored as Int for direct use in pointer operations.
        @usableFromInline
        package let _wordCount: Int

        /// The capacity in bits.
        public let capacity: Bit.Index.Count

        /// Creates a bit vector with the specified capacity.
        ///
        /// All bits are initially cleared (false).
        ///
        /// - Parameter capacity: The number of bits to track.
        @inlinable
        public init(capacity: Bit.Index.Count) {
            let capacityInt = Int(bitPattern: capacity)
            let wordCount = (capacityInt + UInt.bitWidth - 1) / UInt.bitWidth

            self._wordCount = wordCount
            self.capacity = capacity

            if wordCount > 0 {
                unsafe self._words = .allocate(capacity: wordCount)
                unsafe _words.initialize(repeating: 0, count: wordCount)
            } else {
                unsafe self._words = .init(bitPattern: 0x1)!  // Non-null sentinel for empty
            }
        }

        deinit {
            if _wordCount > 0 {
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
            let position = Int(bitPattern: index)
            let word = position / UInt.bitWidth
            let bit = position % UInt.bitWidth
            return unsafe (_words[word] & (1 << bit)) != 0
        }
        nonmutating set {
            let position = Int(bitPattern: index)
            let word = position / UInt.bitWidth
            let bit = position % UInt.bitWidth
            if newValue {
                unsafe _words[word] |= (1 << bit)
            } else {
                unsafe _words[word] &= ~(1 << bit)
            }
        }
    }
}

// MARK: - Bulk Operations

extension Bit.Vector {
    /// Clears all bits to false.
    @inlinable
    public func clearAll() {
        for i in 0..<_wordCount {
            unsafe _words[i] = 0
        }
    }

    /// Sets all bits to true.
    @inlinable
    public func setAll() {
        for i in 0..<_wordCount {
            unsafe _words[i] = ~0
        }

        // Clear excess bits in last word if capacity is not word-aligned
        let capacityInt = Int(bitPattern: capacity)
        let excessBits = _wordCount * UInt.bitWidth - capacityInt
        if excessBits > 0 && _wordCount > 0 {
            let mask = UInt.max >> excessBits
            unsafe _words[_wordCount - 1] &= mask
        }
    }

    /// The number of bits set to true.
    ///
    /// - Complexity: O(n/64) using hardware popcount.
    @inlinable
    public var popcount: Bit.Index.Count {
        var total: UInt = 0
        for i in 0..<_wordCount {
            total += UInt(unsafe _words[i].nonzeroBitCount)
        }
        return Bit.Index.Count(Cardinal(total))
    }

    /// Whether all bits are false.
    @inlinable
    public var isEmpty: Bool {
        for i in 0..<_wordCount {
            if unsafe _words[i] != 0 { return false }
        }
        return true
    }

    /// Whether all bits are true.
    @inlinable
    public var isFull: Bool {
        popcount == capacity
    }
}

// MARK: - Iteration

extension Bit.Vector {
    /// Calls the closure for each index where the bit is set.
    ///
    /// - Parameter body: A closure that receives each set bit's index.
    /// - Complexity: O(popcount) — only visits set bits.
    @inlinable
    public func forEachSetBit(_ body: (Bit.Index) -> Void) {
        let capacityInt = Int(bitPattern: capacity)

        for wordIndex in 0..<_wordCount {
            let baseOffset = wordIndex * UInt.bitWidth
            unsafe _words[wordIndex].forEachSetBit { bitIndex in
                let globalBit = baseOffset + bitIndex
                if globalBit < capacityInt {
                    body(Bit.Index(Ordinal(UInt(globalBit))))
                }
            }
        }
    }
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
