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

extension Bit.Vector {
    /// Non-mutating accessor for iterating set bits.
    ///
    /// Returns a lightweight view that borrows the word pointer, word count,
    /// and capacity. Safe to use from any context including `deinit`. The
    /// returned view cannot outlive `self` — escaping it past this vector's
    /// lifetime is rejected at compile time.
    @inlinable
    public var ones: Ones.View {
        @_lifetime(borrow self)
        borrowing get {
            Ones.View(vector: self)
        }
    }
}
