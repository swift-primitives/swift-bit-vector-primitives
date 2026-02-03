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

// MARK: - Bit.Vector.Static

extension Bit.Vector {
    /// Fixed-capacity packed bit storage with inline (stack) allocation.
    ///
    /// `Bit.Vector.Static` uses `InlineArray` for zero-allocation storage
    /// with compile-time capacity. Ideal for small, fixed-size bit sets
    /// where heap allocation is unnecessary.
    ///
    /// ## Capacity
    ///
    /// The `wordCount` parameter specifies the number of `UInt` words.
    /// Actual bit capacity is `wordCount * UInt.bitWidth` (64 bits per word
    /// on 64-bit platforms).
    ///
    /// ```swift
    /// // 64 bits (1 word)
    /// var flags = Bit.Vector.Static<1>()
    ///
    /// // 256 bits (4 words)
    /// var larger = Bit.Vector.Static<4>()
    /// ```
    public struct Static<let wordCount: Int>: Sendable {
        @usableFromInline
        package var _storage: InlineArray<wordCount, UInt>

        /// The capacity in bits.
        @inlinable
        public static var capacity: Bit.Index.Count {
            Bit.Index.Count(Cardinal(UInt(wordCount * UInt.bitWidth)))
        }

        /// Creates a bit vector with all bits cleared.
        @inlinable
        public init() {
            self._storage = InlineArray(repeating: 0)
        }
    }
}

// MARK: - Subscript Access

extension Bit.Vector.Static {
    /// Gets or sets the bit at the specified index.
    ///
    /// - Parameter index: The bit index. Must be in `0..<capacity`.
    /// - Returns: `true` if the bit is set, `false` otherwise.
    @inlinable
    public subscript(index: Bit.Index) -> Bool {
        get {
            let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
            return (_storage[Int(bitPattern: location.word)] & location.mask) != 0
        }
        set {
            let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
            let word = Int(bitPattern: location.word)
            if newValue {
                _storage[word] |= location.mask
            } else {
                _storage[word] &= ~location.mask
            }
        }
    }
}

// MARK: - Bulk Operations

extension Bit.Vector.Static {
    /// The number of bits set to true.
    ///
    /// - Complexity: O(wordCount) using hardware popcount.
    @inlinable
    public var popcount: Bit.Index.Count {
        var count: UInt = 0
        for i in 0..<wordCount {
            count += UInt(_storage[i].nonzeroBitCount)
        }
        return Bit.Index.Count(Cardinal(count))
    }

    /// Whether all bits are false.
    @inlinable
    public var isEmpty: Bool {
        for i in 0..<wordCount {
            if _storage[i] != 0 { return false }
        }
        return true
    }

    /// Whether all bits are true.
    @inlinable
    public var isFull: Bool {
        for i in 0..<wordCount {
            if _storage[i] != ~0 { return false }
        }
        return true
    }
}

