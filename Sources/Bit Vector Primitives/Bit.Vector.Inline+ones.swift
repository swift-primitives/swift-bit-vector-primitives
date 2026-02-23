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

extension Bit.Vector.Inline {
    /// A sequence of set-bit indices.
    ///
    /// Returns a `Bit.Vector.Ones.Inline` that copies the word storage
    /// and conforms to `Swift.Sequence`, providing `forEach`, `map`,
    /// `filter`, `for-in`, and all stdlib sequence algorithms.
    @inlinable
    public var ones: Bit.Vector.Ones.Inline<wordCount> {
        Bit.Vector.Ones.Inline<wordCount>(storage: _storage, capacity: _count)
    }
}
