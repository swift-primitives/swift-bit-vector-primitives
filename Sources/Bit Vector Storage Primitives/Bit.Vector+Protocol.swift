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

// MARK: - Bit.Vector: Bit.Vector.Protocol

// reason: conformance clause — `Self` is invalid here (the extension's
// inheritance clause establishes what Self even is; svg 60e00fd precedent).
// swiftlint:disable:next prefer_self_in_static_references
extension Bit.Vector: Bit.Vector.`Protocol` {
    /// The capacity in bits.
    @inlinable
    public var bitCapacity: Bit.Index.Count { capacity }

    /// Returns the backing word at the given word index.
    @inlinable
    public borrowing func word(at index: Int) -> UInt {
        unsafe _words[index]
    }

    /// Sets the backing word at the given word index.
    @inlinable
    public mutating func setWord(at index: Int, to value: UInt) {
        unsafe _words[index] = value
    }

    // subscript(index: Bit.Index) -> Bool { get set } — already provided
}
