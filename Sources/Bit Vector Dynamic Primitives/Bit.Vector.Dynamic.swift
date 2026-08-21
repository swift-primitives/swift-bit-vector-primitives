import Affine_Primitives

extension Bit.Vector {

    public struct Dynamic: Sendable {
        @usableFromInline
        var _storage: ContiguousArray<UInt>

        @usableFromInline
        var _count: Bit.Index.Count

        @inlinable
        public init() {
            self._storage = []
            self._count = .zero
        }

        @inlinable
        public init(count: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
            self._storage = ContiguousArray(repeating: 0, count: pack.words.count)
            self._count = count
        }

        @inlinable
        public init(repeating value: Bool, count: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
            self._storage = ContiguousArray(repeating: value ? ~0 : 0, count: pack.words.count)
            self._count = count

            if value && count > .zero && pack.bits.unused > .zero {
                let mask: UInt = ~0 >> pack.bits.unused
                _storage[_storage.endIndex - 1] = mask
            }
        }

        @inlinable
        public init(repeating bit: Bit, count: Bit.Index.Count) {
            self.init(repeating: Bool(bit), count: count)
        }

        @inlinable
        public init<S: Swift.Sequence>(_ elements: S) where S.Element == Bool {
            self.init()
            for element in elements {
                append(element)
            }
        }

        @inlinable
        public init<S: Swift.Sequence>(_ elements: S) where S.Element == Bit {
            self.init()
            for element in elements {
                append(Bool(element))
            }
        }

    }
}

extension Bit.Vector.Dynamic {

    public typealias Error = __BitVectorDynamicError
}

extension Bit.Vector.Dynamic {

    @inlinable
    public var count: Bit.Index.Count { _count }

    @inlinable
    public var isEmpty: Bool { _count == .zero }

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

    @usableFromInline
    var _wordCount: Int { _storage.count }
}

extension Bit.Vector.Dynamic {

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
