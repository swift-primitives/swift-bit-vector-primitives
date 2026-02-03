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
    public var `set`: Property<Set, Self>.View {
        mutating _read {
            yield unsafe Property<Set, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Set, Self>.View(&self)
            yield &view
        }
    }
}

extension Property.View where Tag == Bit.Vector.Set, Base == Bit.Vector {
    /// Sets all bits to true.
    @inlinable
    public func all() {
        let wordCount = unsafe base.pointee._wordCount
        for i in 0..<wordCount {
            unsafe base.pointee._words[i] = ~0
        }

        // Clear excess bits in last word if capacity is not word-aligned
        let capacityInt = Int(bitPattern: unsafe base.pointee.capacity)
        let excessBits = wordCount * UInt.bitWidth - capacityInt
        if excessBits > 0 && wordCount > 0 {
            let mask = UInt.max >> excessBits
            unsafe base.pointee._words[wordCount - 1] &= mask
        }
    }
}
