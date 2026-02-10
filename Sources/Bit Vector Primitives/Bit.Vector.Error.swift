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

// MARK: - Hoisted Error Types
//
// Error types are hoisted to module level for typed throws compatibility.
// Use the typealias (e.g., `Bit.Vector.Dynamic.Error`) in your code.

/// Errors that can occur during `Bit.Vector.Dynamic` operations.
public enum __BitVectorDynamicError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case invalidCount
}

/// Errors that can occur during `Bit.Vector.Bounded` operations.
public enum __BitVectorBoundedError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case invalidCount
    case overflow
}

/// Errors that can occur during `Bit.Vector.Inline` operations.
public enum __BitVectorInlineError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case overflow
}
