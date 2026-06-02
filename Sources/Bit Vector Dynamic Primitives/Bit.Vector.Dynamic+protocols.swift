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

extension Bit.Vector.Dynamic: Equatable {
    /// Returns whether two dynamic vectors hold the same bits.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        guard lhs._storage.count == rhs._storage.count else { return false }
        for i in 0..<lhs._storage.count {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension Bit.Vector.Dynamic: Hashable {
    /// Feeds the vector's bits into the given hasher.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_count)
        hasher.combine(_storage)
    }
}

// MARK: - CustomStringConvertible

extension Bit.Vector.Dynamic: CustomStringConvertible {
    /// A textual representation of the value.
    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Dynamic(\(bits)\(suffix))"
    }
}
