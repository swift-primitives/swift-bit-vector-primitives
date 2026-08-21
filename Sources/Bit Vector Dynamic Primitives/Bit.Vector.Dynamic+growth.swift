import Affine_Primitives

extension Bit.Vector.Dynamic {

    @inlinable
    public mutating func append(_ value: Bool) {
        let loc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)

        if Int(bitPattern: loc.word) >= _storage.count {
            _storage.append(0)
        }

        if value {
            _storage[loc.word] |= loc.mask
        }

        _count += .one
    }

    @inlinable
    public mutating func append(_ bit: Bit) {
        append(Bool(bit))
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
    public mutating func removeAll(keepingCapacity: Bool = false) {
        if keepingCapacity {
            for i in 0..<_storage.count {
                _storage[i] = 0
            }
        } else {
            _storage.removeAll()
        }
        _count = .zero
    }
}

extension Bit.Vector.Dynamic {

    @inlinable
    public mutating func resize(to newCount: Bit.Index.Count, fill: Bool = false) {
        let newPack = Bit.Pack<UInt>(count: newCount, bitsPerWord: .bitsPerWord)
        let oldWordCount = _storage.count
        let newWordCount = Int(bitPattern: newPack.words.count)

        if newWordCount > oldWordCount {
            let fillValue: UInt = fill ? ~0 : 0
            _storage.reserveCapacity(newWordCount)
            for _ in oldWordCount..<newWordCount {
                _storage.append(fillValue)
            }
        } else if newWordCount < oldWordCount {
            _storage.removeLast(oldWordCount - newWordCount)
        }

        if fill && newCount > _count && oldWordCount > 0 {
            let oldLoc = Bit.Pack<UInt>.Location(count: _count, bitsPerWord: .bitsPerWord)
            if oldLoc.bit > .zero && oldLoc.word < newPack.words.count {
                let highMask: UInt = ~0 << oldLoc.bit.magnitude
                _storage[oldLoc.word] |= highMask
            }
        }

        _count = newCount

        if newWordCount > 0 && newPack.bits.unused > .zero {
            let lastWord = newWordCount - 1
            let mask: UInt = ~0 >> newPack.bits.unused
            _storage[lastWord] &= mask
        }
    }
}
