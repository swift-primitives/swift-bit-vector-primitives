import Index_Primitives
import Property_Primitives

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public var wordCount: Int {
        Int(bitPattern: Bit.Pack<UInt>(count: bitCapacity, bitsPerWord: .bitsPerWord).words.count)
    }
}

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public var popcount: Bit.Index.Count {
        var total: UInt = 0
        for i in 0..<wordCount {
            total += UInt(word(at: i).nonzeroBitCount)
        }
        return Bit.Index.Count(Cardinal(total))
    }
}

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public var allFalse: Bool {
        for i in 0..<wordCount {
            if word(at: i) != 0 { return false }
        }
        return true
    }

    @inlinable
    public var allTrue: Bool {
        popcount == bitCapacity
    }
}

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public static func clearAll(_ vector: inout Self) {
        for i in 0..<vector.wordCount {
            vector.setWord(at: i, to: 0)
        }
    }

    @inlinable
    public static func setAll(_ vector: inout Self) {
        let pack = Bit.Pack<UInt>(count: vector.bitCapacity, bitsPerWord: .bitsPerWord)
        let wc = vector.wordCount
        for i in 0..<wc {
            vector.setWord(at: i, to: ~0)
        }
        if pack.bits.unused > .zero && wc > 0 {
            vector.setWord(at: wc - 1, to: ~0 >> pack.bits.unused)
        }
    }
}

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public mutating func popFirst() -> Bit.Index? {
        for i in 0..<wordCount {
            let w = word(at: i)
            if w != 0 {
                let location = Bit.Pack<UInt>.Location(
                    word: .init(Ordinal(UInt(i))),
                    bit: .init(Affine.Discrete.Vector(w.trailingZeroBitCount))
                )
                setWord(at: i, to: w & (w &- 1))
                let globalIndex = location.index(bitsPerWord: .bitsPerWord)
                guard globalIndex < bitCapacity else { return nil }
                return globalIndex
            }
        }
        return nil
    }
}

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public var any: Bool { !allFalse }
}

extension Bit.Vector.`Protocol` where Self: ~Copyable {

    @inlinable
    public var pop: Property<Bit.Vector.Pop, Self>.Inout {
        mutating _read {
            yield Property<Bit.Vector.Pop, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Bit.Vector.Pop, Self>.Inout(&self)
            yield &accessor
        }
    }

    @inlinable
    public var `set`: Property<Bit.Vector.Set, Self>.Inout {
        mutating _read {
            yield Property<Bit.Vector.Set, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Bit.Vector.Set, Self>.Inout(&self)
            yield &accessor
        }
    }

    @inlinable
    public var clear: Property<Bit.Vector.Clear, Self>.Inout {
        mutating _read {
            yield Property<Bit.Vector.Clear, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Bit.Vector.Clear, Self>.Inout(&self)
            yield &accessor
        }
    }
}

extension Property.Inout where Tag == Bit.Vector.Pop, Base: Bit.Vector.`Protocol` & ~Copyable {

    @inlinable
    public mutating func first() -> Bit.Index? {
        base.value.popFirst()
    }
}

extension Property.Inout where Tag == Bit.Vector.Set, Base: Bit.Vector.`Protocol` & ~Copyable {

    @inlinable
    public mutating func all() {
        Base.setAll(&base.value)
    }
}

extension Property.Inout where Tag == Bit.Vector.Clear, Base: Bit.Vector.`Protocol` & ~Copyable {

    @inlinable
    public mutating func all() {
        Base.clearAll(&base.value)
    }
}
