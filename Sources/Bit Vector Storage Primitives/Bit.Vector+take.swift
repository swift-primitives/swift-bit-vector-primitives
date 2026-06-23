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

extension Bit.Vector {
    /// Moves this vector's contents to a new vector and replaces self with empty.
    ///
    /// After this call, `self` contains an empty vector with the same capacity,
    /// and the returned vector holds the original bit data.
    ///
    /// This enables ownership transfer of ~Copyable bitmap data across module
    /// boundaries where partial consumption is not allowed.
    ///
    /// - Returns: A new vector containing this vector's original bit data.
    /// - Complexity: O(1) — swaps internal pointers.
    @inlinable
    public mutating func take() -> Bit.Vector {
        var empty = Bit.Vector(capacity: capacity)
        swap(&self, &empty)
        return empty
    }
}
