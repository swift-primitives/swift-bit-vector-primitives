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

extension Bit.Vector.Zeros {
    /// A lightweight non-mutating view for iterating clear bits.
    ///
    /// Captures the word pointer, word count, and capacity from `Bit.Vector`
    /// without requiring exclusive access. This enables `zeros.forEach` to work
    /// from non-mutating contexts (including `deinit`).
    @safe
    // WHY: Deliberately NOT `Sendable`. This view is a `Copyable` alias to the
    // WHY: same base pointer as its owning `Bit.Vector`, freely obtainable from
    // WHY: a borrow. A `Sendable` conformance here would defeat the removal of
    // WHY: `Sendable` on `Bit.Vector` itself — see `Bit.Vector.swift`.
    public struct View: Copyable {
        @usableFromInline
        let _words: UnsafeMutablePointer<UInt>

        @usableFromInline
        let _wordCount: Index_Primitives.Index<UInt>.Count

        @usableFromInline
        let _capacity: Bit.Index.Count

        @inlinable
        package init(
            words: UnsafeMutablePointer<UInt>,
            wordCount: Index_Primitives.Index<UInt>.Count,
            capacity: Bit.Index.Count
        ) {
            unsafe self._words = words
            self._wordCount = wordCount
            self._capacity = capacity
        }
    }
}
