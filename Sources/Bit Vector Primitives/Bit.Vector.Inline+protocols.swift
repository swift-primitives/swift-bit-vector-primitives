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

extension Bit.Vector.Inline: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        let pack = Bit.Pack<UInt>(count: lhs._count, bitsPerWord: .bitsPerWord)
        let wordCountInt = Int(bitPattern: pack.words.count)
        for i in 0..<wordCountInt {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension Bit.Vector.Inline: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        let wordCountInt = Int(bitPattern: pack.words.count)
        hasher.combine(_count)
        for i in 0..<wordCountInt {
            hasher.combine(_storage[i])
        }
    }
}

// MARK: - CustomStringConvertible

extension Bit.Vector.Inline: CustomStringConvertible {
    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Inline<\(wordCount)>(\(bits)\(suffix))"
    }
}
