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

import Property_Primitives

// MARK: - Property: ones.forEach

extension Bit.Vector.Dynamic {
    /// Property view for iterating set (true) bit indices.
    ///
    /// Uses Wegner/Kernighan word-level bit manipulation for efficient sparse iteration.
    ///
    /// ```swift
    /// var bits = Bit.Vector.Dynamic([true, false, true, false])
    /// bits.ones.forEach { index in
    ///     print(index)  // 0, 2
    /// }
    /// ```
    @inlinable
    public var ones: Property<Bit.Vector.Ones, Self>.View {
        mutating _read {
            yield unsafe Property<Bit.Vector.Ones, Self>.View(&self)
        }
    }
}

extension Property.View where Tag == Bit.Vector.Ones, Base == Bit.Vector.Dynamic {
    /// Iterates over indices of set (true) bits.
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        let storage = unsafe base.value._storage
        let count = unsafe base.value._count
        let countInt = Int(clamping: count)
        let bitsPerWord = UInt.bitWidth

        for (wordIndex, var word) in storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * bitsPerWord + bitIndex
                if globalIndex < countInt {
                    body(Bit.Index(__unchecked: (), Ordinal(UInt(globalIndex))))
                }
                word &= word &- 1
            }
        }
    }
}
