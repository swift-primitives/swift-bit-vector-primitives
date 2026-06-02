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

import Affine_Primitives

// MARK: - Dynamic from Bounded

extension Bit.Vector.Dynamic {
    /// Creates a dynamic vector from a bounded vector.
    @inlinable
    public init(_ bounded: Bit.Vector.Bounded) {
        self._storage = bounded._storage
        self._count = bounded._count
    }
}

// MARK: - Dynamic from Inline

extension Bit.Vector.Dynamic {
    /// Creates a dynamic vector from an inline vector.
    @inlinable
    public init<let wordCount: Int>(_ inline: Bit.Vector.Inline<wordCount>) {
        let pack = Bit.Pack<UInt>(count: inline._count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        self._storage = ContiguousArray<UInt>()
        self._storage.reserveCapacity(pack.words.count)
        var w: Index<UInt> = .zero
        while w < end {
            self._storage.append(inline._storage[w])
            w += Index<UInt>.Count.one
        }
        self._count = inline._count
    }
}
