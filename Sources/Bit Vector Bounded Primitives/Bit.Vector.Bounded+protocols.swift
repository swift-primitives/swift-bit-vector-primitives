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

// MARK: - Equatable

extension Bit.Vector.Bounded: Equatable {
    /// Returns whether two bounded vectors hold the same bits.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        let pack = Bit.Pack<UInt>(count: lhs._count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        var w: Index<UInt> = .zero
        while w < end {
            if lhs._storage[w] != rhs._storage[w] { return false }
            w += Index<UInt>.Count.one
        }
        return true
    }
}

// MARK: - Hashable

extension Bit.Vector.Bounded: Hashable {
    /// Feeds the vector's bits into the given hasher.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        hasher.combine(_count)
        var w: Index<UInt> = .zero
        while w < end {
            hasher.combine(_storage[w])
            w += Index<UInt>.Count.one
        }
    }
}

// MARK: - CustomStringConvertible

extension Bit.Vector.Bounded: CustomStringConvertible {
    /// A textual representation of the value.
    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Bounded(\(bits)\(suffix), capacity: \(Int(clamping: _capacity)))"
    }
}
