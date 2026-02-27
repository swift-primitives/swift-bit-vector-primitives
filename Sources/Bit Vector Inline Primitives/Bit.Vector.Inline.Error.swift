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

// Hoisted error type for typed throws compatibility.
// Use `Bit.Vector.Inline.Error` in your code, not this type directly.

/// Errors that can occur during `Bit.Vector.Inline` operations.
public enum __BitVectorInlineError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case overflow
}
