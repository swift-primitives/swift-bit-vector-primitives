extension Bit.Vector.Inline {

    @inlinable
    public var zeros: Bit.Vector.Zeros.Inline<wordCount> {
        Bit.Vector.Zeros.Inline<wordCount>(storage: _storage, capacity: _count)
    }
}
