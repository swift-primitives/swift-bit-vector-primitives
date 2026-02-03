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

extension Bit.Vector.Static {
    @inlinable
    public var clear: Property<Bit.Vector.Clear, Self>.View {
        mutating _read {
            yield unsafe Property<Bit.Vector.Clear, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Bit.Vector.Clear, Self>.View(&self)
            yield &view
        }
    }
}

extension Property.View where Tag == Bit.Vector.Clear {
    /// Clears all bits to false.
    @inlinable
    public func all<let wordCount: Int>() where Base == Bit.Vector.Static<wordCount> {
        for i in 0..<wordCount {
            unsafe base.pointee._storage[i] = 0
        }
    }
}
