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

extension Bit.Vector {
    @inlinable
    public var ones: Property<Ones, Self>.View {
        mutating _read {
            yield unsafe Property<Ones, Self>.View(&self)
        }
    }
}

extension Property.View where Tag == Bit.Vector.Ones, Base == Bit.Vector {
    /// Calls the closure for each index where the bit is set.
    ///
    /// - Parameter body: A closure that receives each set bit's index.
    /// - Complexity: O(popcount) — only visits set bits.
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        let capacityInt = Int(bitPattern: unsafe base.pointee.capacity)
        let wordCount = unsafe base.pointee._wordCount

        for wordIndex in 0..<wordCount {
            let baseOffset = wordIndex * UInt.bitWidth
            unsafe base.pointee._words[wordIndex].forEachSetBit { bitIndex in
                let globalBit = baseOffset + bitIndex
                if globalBit < capacityInt {
                    body(Bit.Index(Ordinal(UInt(globalBit))))
                }
            }
        }
    }
}
