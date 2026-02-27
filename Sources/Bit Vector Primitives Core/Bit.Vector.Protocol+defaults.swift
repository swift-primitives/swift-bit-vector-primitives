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

import Index_Primitives
import Property_Primitives

// MARK: - Derived Word Count

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    /// The number of `UInt` words in backing storage.
    ///
    /// Derived from `bitCapacity` via `Bit.Pack<UInt>`.
    @inlinable
    public var wordCount: Int {
        Int(bitPattern: Bit.Pack<UInt>(count: bitCapacity, bitsPerWord: .bitsPerWord).words.count)
    }
}

// MARK: - Popcount

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    /// The number of bits set to true.
    ///
    /// - Complexity: O(n/64) using hardware popcount.
    @inlinable
    public var popcount: Bit.Index.Count {
        var total: UInt = 0
        for i in 0..<wordCount {
            total += UInt(word(at: i).nonzeroBitCount)
        }
        return Bit.Index.Count(Cardinal(total))
    }
}

// MARK: - All False / All True

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    /// Whether all bits are false (no bits set).
    @inlinable
    public var allFalse: Bool {
        for i in 0..<wordCount {
            if word(at: i) != 0 { return false }
        }
        return true
    }

    /// Whether all bits are true (up to capacity).
    @inlinable
    public var allTrue: Bool {
        popcount == bitCapacity
    }
}

// MARK: - Clear All / Set All

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    /// Clears all bits to false.
    ///
    /// Core logic as static method per [IMPL-023]. Instance method and
    /// `Property.View` `.clear.all()` both delegate here.
    @inlinable
    public static func clearAll(_ vector: inout Self) {
        for i in 0..<vector.wordCount {
            vector.setWord(at: i, to: 0)
        }
    }

    /// Sets all bits to true (up to capacity).
    ///
    /// Core logic as static method per [IMPL-023]. Property.View
    /// `.set.all()` delegates here.
    @inlinable
    public static func setAll(_ vector: inout Self) {
        let pack = Bit.Pack<UInt>(count: vector.bitCapacity, bitsPerWord: .bitsPerWord)
        let wc = vector.wordCount
        for i in 0..<wc {
            vector.setWord(at: i, to: ~0)
        }
        if pack.bits.unused > .zero && wc > 0 {
            vector.setWord(at: wc - 1, to: ~0 >> pack.bits.unused)
        }
    }
}

// MARK: - Pop First

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    /// Removes and returns the index of the lowest set bit.
    ///
    /// Scans words from the start, extracts the lowest set bit using
    /// Wegner/Kernighan (`w &= w &- 1`), clears it in the backing storage,
    /// and returns the global bit index.
    ///
    /// - Returns: The index of the lowest set bit, or `nil` if no bits are set.
    /// - Complexity: O(words) per call, O(words * popcount) total for full drain.
    @inlinable
    public mutating func popFirst() -> Bit.Index? {
        for i in 0..<wordCount {
            let w = word(at: i)
            if w != 0 {
                let location = Bit.Pack<UInt>.Location(
                    word: .init(Ordinal(UInt(i))),
                    bit: .init(Affine.Discrete.Vector(w.trailingZeroBitCount))
                )
                setWord(at: i, to: w & (w &- 1))
                let globalIndex = location.index(bitsPerWord: .bitsPerWord)
                guard globalIndex < bitCapacity else { return nil }
                return globalIndex
            }
        }
        return nil
    }
}

// MARK: - Any

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    /// Whether any bit is true.
    @inlinable
    public var any: Bool { !allFalse }
}

// MARK: - Property.View Accessors

extension Bit.Vector.`Protocol` where Self: ~Copyable {
    @inlinable
    public var pop: Property<Bit.Vector.Pop, Self>.View {
        mutating _read {
            yield unsafe Property<Bit.Vector.Pop, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Bit.Vector.Pop, Self>.View(&self)
            yield &view
        }
    }

    @inlinable
    public var `set`: Property<Bit.Vector.Set, Self>.View {
        mutating _read {
            yield unsafe Property<Bit.Vector.Set, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Bit.Vector.Set, Self>.View(&self)
            yield &view
        }
    }

    @inlinable
    public var clear: Property<Bit.Vector.Clear, Self>.View {
        mutating _read {
            yield unsafe Property<Bit.Vector.Clear, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Bit.Vector.Clear, Self>.View(&self)
            yield &view
        }
    }
}

// MARK: - Property.View Methods

extension Property.View where Tag == Bit.Vector.Pop, Base: Bit.Vector.`Protocol` & ~Copyable {
    /// Removes and returns the index of the lowest set bit.
    ///
    /// - Returns: The index of the lowest set bit, or `nil` if no bits are set.
    /// - Complexity: O(words) per call, O(words * popcount) total for full drain.
    @inlinable
    public func first() -> Bit.Index? {
        unsafe base.pointee.popFirst()
    }
}

extension Property.View where Tag == Bit.Vector.Set, Base: Bit.Vector.`Protocol` & ~Copyable {
    /// Sets all bits to true.
    @inlinable
    public mutating func all() {
        unsafe Base.setAll(&base.pointee)
    }
}

extension Property.View where Tag == Bit.Vector.Clear, Base: Bit.Vector.`Protocol` & ~Copyable {
    /// Clears all bits to false.
    @inlinable
    public mutating func all() {
        unsafe Base.clearAll(&base.pointee)
    }
}

