extension Bit.Vector.Static {

    @inlinable
    public var zeros: Bit.Vector.Zeros.Static<wordCount> {
        Bit.Vector.Zeros.Static<wordCount>(storage: _storage)
    }
}
