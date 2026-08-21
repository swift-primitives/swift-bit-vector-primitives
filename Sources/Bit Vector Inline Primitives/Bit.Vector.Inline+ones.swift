extension Bit.Vector.Inline {

    @inlinable
    public var ones: Bit.Vector.Ones.Inline<wordCount> {
        Bit.Vector.Ones.Inline<wordCount>(storage: _storage, capacity: _count)
    }
}
