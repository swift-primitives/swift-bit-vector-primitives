import Affine_Primitives

extension Bit.Vector {

    public struct Bounded: Sendable {
        @usableFromInline
        let _capacity: Bit.Index.Count

        @usableFromInline
        package var _storage: ContiguousArray<UInt>

        @usableFromInline
        package var _count: Bit.Index.Count

        @inlinable
        public init(capacity: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)
            self._capacity = capacity
            self._storage = ContiguousArray(repeating: 0, count: pack.words.count)
            self._count = .zero
        }

        @inlinable
        public init(capacity: Bit.Index.Count, count: Bit.Index.Count) throws(Self.Error) {
            guard count <= capacity else {
                throw .overflow
            }
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)
            self._capacity = capacity
            self._storage = ContiguousArray(repeating: 0, count: pack.words.count)
            self._count = count
        }

        @inlinable
        public init<S: Swift.Sequence>(capacity: Bit.Index.Count, _ elements: S) throws(Self.Error)
        where S.Element == Bool {
            self.init(capacity: capacity)
            for element in elements {
                try append(element)
            }
        }

        @inlinable
        public init(
            capacity: Bit.Index.Count,
            repeating value: Bool,
            count: Bit.Index.Count
        ) throws(Self.Error) {
            guard count <= capacity else {
                throw .overflow
            }
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)
            self._capacity = capacity
            self._storage = ContiguousArray(repeating: value ? ~0 : 0, count: pack.words.count)
            self._count = count

            if value && count > .zero {
                let countPack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
                if countPack.bits.unused > .zero {

                    let lastWord = try! countPack.words.count.map(Ordinal.init).predecessor.exact()
                    let mask: UInt = ~0 >> countPack.bits.unused
                    _storage[lastWord] = mask
                }

                let countWords = Int(bitPattern: countPack.words.count)
                for i in countWords..<_storage.count {
                    _storage[i] = 0
                }
            }
        }

    }
}

extension Bit.Vector.Bounded {

    public typealias Error = __BitVectorBoundedError
}

extension Bit.Vector.Bounded {

    @inlinable
    public var count: Bit.Index.Count { _count }

    @inlinable
    public var isEmpty: Bool { _count == .zero }

    @inlinable
    public var isFull: Bool { _count >= _capacity }

    @inlinable
    public var first: Bool? {
        guard _count > .zero else { return nil }
        return (_storage[0] & 1) != 0
    }

    @inlinable
    public var last: Bool? {
        guard _count > .zero else { return nil }
        let lastIndex = _count.subtract.saturating(.one)
        let loc = Bit.Pack<UInt>.Location(count: lastIndex, bitsPerWord: .bitsPerWord)
        return (_storage[loc.word] & loc.mask) != 0
    }
}

extension Bit.Vector.Bounded {

    @inlinable
    public subscript(index: Bit.Index) -> Bool {
        get {
            precondition(index < _count, "Index out of bounds")
            let loc = index.location(bitsPerWord: .bitsPerWord)
            return (_storage[loc.word] & loc.mask) != 0
        }
        set {
            precondition(index < _count, "Index out of bounds")
            let loc = index.location(bitsPerWord: .bitsPerWord)
            if newValue {
                _storage[loc.word] |= loc.mask
            } else {
                _storage[loc.word] &= ~loc.mask
            }
        }
    }

    @inlinable
    public func get(_ index: Bit.Index) throws(Self.Error) -> Bool {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        return (_storage[loc.word] & loc.mask) != 0
    }
}
