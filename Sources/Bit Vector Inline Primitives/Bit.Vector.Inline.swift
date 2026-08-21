import Affine_Primitives

extension Bit.Vector {

    public struct Inline<let wordCount: Int>: Sendable {

        @inlinable
        public static var _capacity: Bit.Index.Count {
            Bit.Index.Count(Cardinal(UInt(wordCount * UInt.bitWidth)))
        }

        @usableFromInline
        package var _storage: InlineArray<wordCount, UInt>

        @usableFromInline
        package var _count: Bit.Index.Count

        @inlinable
        public init() {
            self._storage = InlineArray(repeating: 0)
            self._count = .zero
        }

        @inlinable
        public init(count: Bit.Index.Count) throws(Self.Error) {
            guard count <= Self._capacity else {
                throw .overflow
            }
            self._storage = InlineArray(repeating: 0)
            self._count = count
        }

        @inlinable
        public init(repeating value: Bool, count: Bit.Index.Count) throws(Self.Error) {
            guard count <= Self._capacity else {
                throw .overflow
            }
            self._storage = InlineArray(repeating: value ? ~0 : 0)
            self._count = count

            if value && count > .zero {
                let pack = Bit.Pack<UInt>(count: count, bitsPerWord: .bitsPerWord)
                if pack.bits.unused > .zero {

                    let lastWordIndex = try! pack.words.count.map(Ordinal.init).predecessor.exact()
                    let mask: UInt = ~0 >> pack.bits.unused
                    _storage[lastWordIndex] = mask
                }

                let countWords = Int(bitPattern: pack.words.count)
                for i in countWords..<wordCount {
                    _storage[i] = 0
                }
            }
        }

        public typealias Error = __BitVectorInlineError
    }
}

extension Bit.Vector.Inline {

    @inlinable
    public var count: Bit.Index.Count { _count }

    @inlinable
    public var isEmpty: Bool { _count == .zero }

    @inlinable
    public var isFull: Bool { _count >= Self._capacity }

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

extension Bit.Vector.Inline {

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
