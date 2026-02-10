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
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        let pack = Bit.Pack<UInt>(count: lhs._count, bitsPerWord: .bitsPerWord)
        let wordCount = Int(bitPattern: pack.words.count)
        for i in 0..<wordCount {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension Bit.Vector.Bounded: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        let wordCount = Int(bitPattern: pack.words.count)
        hasher.combine(_count)
        for i in 0..<wordCount {
            hasher.combine(_storage[i])
        }
    }
}

// MARK: - CustomStringConvertible

extension Bit.Vector.Bounded: CustomStringConvertible {
    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Bounded(\(bits)\(suffix), capacity: \(Int(clamping: _capacity)))"
    }
}
