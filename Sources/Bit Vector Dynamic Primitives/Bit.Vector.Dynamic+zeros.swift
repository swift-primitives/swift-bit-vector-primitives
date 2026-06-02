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

// MARK: - Property: zeros.forEach

extension Bit.Vector.Dynamic {
    /// Property view for iterating clear (false) bit indices.
    ///
    /// Uses complement + Wegner/Kernighan word-level bit manipulation
    /// for efficient sparse iteration of zero bits.
    ///
    /// ```swift
    /// var bits = Bit.Vector.Dynamic([true, false, true, false])
    /// bits.zeros.forEach { index in
    ///     print(index)  // 1, 3
    /// }
    /// ```
    @inlinable
    public var zeros: Property<Bit.Vector.Zeros, Self>.Inout {
        mutating _read {
            yield Property<Bit.Vector.Zeros, Self>.Inout(&self)
        }
    }
}

extension Property.Inout where Tag == Bit.Vector.Zeros, Base == Bit.Vector.Dynamic {
    /// Iterates over indices of clear (false) bits.
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        let storage = base.value._storage
        let count = base.value._count
        let countInt = Int(clamping: count)
        let bitsPerWord = UInt.bitWidth

        for (wordIndex, word) in storage.enumerated() {
            var inverted = ~word
            while inverted != 0 {
                let bitIndex = inverted.trailingZeroBitCount
                let globalIndex = wordIndex * bitsPerWord + bitIndex
                if globalIndex < countInt {
                    body(Bit.Index(_unchecked: Ordinal(UInt(globalIndex))))
                }
                inverted &= inverted &- 1
            }
        }
    }
}
