import Affine_Primitives

extension Bit.Vector.Inline {

    @inlinable
    public mutating func append(_ value: Bool) throws(Self.Error) {
        guard _count < Self._capacity else {
            throw .overflow
        }
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
        if value {
            _storage[loc.word] |= loc.mask
        }
        _count += .one
    }

    @inlinable
    public mutating func append(_ bit: Bit) throws(Self.Error) {
        try append(Bool(bit))
    }

    @discardableResult
    @inlinable
    public mutating func popLast() -> Bool? {
        guard _count > .zero else { return nil }
        _count = _count.subtract.saturating(.one)
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
        let value = (_storage[loc.word] & loc.mask) != 0
        _storage[loc.word] &= ~loc.mask
        return value
    }

    @inlinable
    public mutating func removeLast() {
        precondition(_count > .zero, "Cannot remove from empty vector")
        _count = _count.subtract.saturating(.one)
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
        _storage[loc.word] &= ~loc.mask
    }

    @inlinable
    public mutating func removeAll() {
        for i in 0..<wordCount {
            _storage[i] = 0
        }
        _count = .zero
    }
}
