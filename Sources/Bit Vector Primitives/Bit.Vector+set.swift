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
import Range_Primitives
import Affine_Primitives

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
        (.zero..<wordCount).forEach { i in
            unsafe base.pointee._words[i] = ~0
        }

        // Clear excess bits in last word if capacity is not word-aligned
        let pack = Bit.Pack<UInt>(count: unsafe base.pointee.capacity, bitsPerWord: .bitsPerWord)
        let unused = pack.bits.unused
        if unused > .zero && wordCount > .zero {
            let location = Bit.Pack<UInt>.Location(count: unsafe base.pointee.capacity, bitsPerWord: .bitsPerWord)
            let mask = UInt.max >> Int(bitPattern: unused)
            let current = unsafe base.pointee._words[location.word]
            unsafe base.pointee._words[location.word] = current & mask
        }
    }
}
