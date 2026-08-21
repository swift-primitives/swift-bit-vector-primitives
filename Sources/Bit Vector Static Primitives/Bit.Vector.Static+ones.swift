extension Bit.Vector.Static {

    @inlinable
    public var ones: Bit.Vector.Ones.Static<wordCount> {
        Bit.Vector.Ones.Static<wordCount>(storage: _storage)
    }
}
