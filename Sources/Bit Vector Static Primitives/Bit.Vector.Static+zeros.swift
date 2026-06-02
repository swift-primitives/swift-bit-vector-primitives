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

extension Bit.Vector.Static {
    /// A sequence of clear-bit indices.
    ///
    /// Returns a `Bit.Vector.Zeros.Static` that copies the inline storage
    /// and conforms to `Swift.Sequence`, providing `forEach`, `map`,
    /// `filter`, `for-in`, and all stdlib sequence algorithms.
    @inlinable
    public var zeros: Bit.Vector.Zeros.Static<wordCount> {
        Bit.Vector.Zeros.Static<wordCount>(storage: _storage)
    }
}
