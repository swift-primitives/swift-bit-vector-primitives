public import Bit_Primitives

extension Bit {

    @safe
    public struct Vector: ~Copyable {
        @usableFromInline
        package var _words: UnsafeMutablePointer<UInt>

        @usableFromInline
        package let _wordCount: Index_Primitives.Index<UInt>.Count

        public let capacity: Bit.Index.Count

        @inlinable
        public init(capacity: Bit.Index.Count) {
            let pack = Bit.Pack<UInt>(count: capacity, bitsPerWord: .bitsPerWord)

            self._wordCount = pack.words.count
            self.capacity = capacity

            if _wordCount > .zero {
                unsafe self._words = .allocate(capacity: _wordCount)
                unsafe _words.initialize(repeating: 0, count: _wordCount)
            } else {

                unsafe self._words = .init(bitPattern: 0x1)!
            }
        }

        deinit {
            if _wordCount > .zero {
                unsafe _words.deallocate()
            }
        }
    }
}

extension Bit.Vector {

    @inlinable
    public subscript(index: Bit.Index) -> Bool {
        get {
            precondition(index < capacity, "Index out of bounds")
            let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
            return unsafe (_words[location.word] & location.mask) != 0
        }
        nonmutating set {
            precondition(index < capacity, "Index out of bounds")
            let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
            let current = unsafe _words[location.word]
            if newValue {
                unsafe _words[location.word] = current | location.mask
            } else {
                unsafe _words[location.word] = current & ~location.mask
            }
        }
    }
}

extension Bit.Vector {

    @inlinable
    public var isEmpty: Bool { allFalse }

    @inlinable
    public var isFull: Bool { allTrue }
}

extension Bit.Vector {

    @inlinable
    public func withUnsafeWords<R>(_ body: (UnsafeBufferPointer<UInt>) -> R) -> R {
        return unsafe body(UnsafeBufferPointer(start: _words, count: _wordCount))
    }

    @inlinable
    public func withUnsafeMutableWords<R>(_ body: (UnsafeMutableBufferPointer<UInt>) -> R) -> R {
        return unsafe body(UnsafeMutableBufferPointer(start: _words, count: _wordCount))
    }
}
