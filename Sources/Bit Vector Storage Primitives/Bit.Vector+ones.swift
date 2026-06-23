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
    /// Returns a lightweight view that captures the word pointer, word count,
    /// and capacity. Safe to use from any context including `deinit`.
    @inlinable
    public var ones: Ones.View {
        unsafe Ones.View(words: _words, wordCount: _wordCount, capacity: capacity)
    }
}
