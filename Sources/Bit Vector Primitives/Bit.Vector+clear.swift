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
    public var clear: Property<Clear, Self>.View {
        mutating _read {
            yield unsafe Property<Clear, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Clear, Self>.View(&self)
            yield &view
        }
    }
}

extension Property.View where Tag == Bit.Vector.Clear, Base == Bit.Vector {
    /// Clears all bits to false.
    @inlinable
    public func all() {
        unsafe (.zero..<base.pointee._wordCount).forEach { i in
            unsafe base.pointee._words[i] = 0
        }
    }
}
