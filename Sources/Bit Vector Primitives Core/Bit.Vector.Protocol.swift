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

// MARK: - Bit.Vector.Protocol

extension Bit.Vector {
    /// A protocol for types that store bits in `UInt` words and share
    /// common bitmap operations.
    ///
    /// All five `Bit.Vector` variants conform:
    ///
    /// - ``Bit.Vector`` (~Copyable, pointer-backed)
    /// - ``Bit.Vector.Static`` (inline, full-capacity bitmap)
    /// - ``Bit.Vector.Bounded`` (heap, fixed-capacity container)
    /// - ``Bit.Vector.Inline`` (inline, fixed-capacity container)
    /// - ``Bit.Vector.Dynamic`` (heap, growable container)
    ///
    /// Conformers provide word-level access (3 requirements + subscript).
    /// The protocol provides default implementations for `popcount`,
    /// `allFalse`, `allTrue`, `clearAll`, `setAll`, and `popFirst`.
    ///
    /// ## Compiler Bug Workaround
    ///
    /// The `subscript` is a protocol requirement rather than a default
    /// implementation because subscript get/set in a `where Self: ~Copyable`
    /// extension crashes the Swift 6.2 compiler with "copy of noncopyable
    /// typed value".
    public protocol `Protocol`: ~Copyable {
        /// The total number of valid bit positions.
        var bitCapacity: Bit.Index.Count { get }

        /// Reads the word at the given index.
        borrowing func word(at index: Int) -> UInt

        /// Writes the word at the given index.
        mutating func setWord(at index: Int, to value: UInt)

        /// Reads or writes a single bit.
        ///
        /// Each conformer provides this (5-line implementation) due to
        /// a compiler bug preventing a default implementation.
        subscript(index: Bit.Index) -> Bool { get set }
    }
}
