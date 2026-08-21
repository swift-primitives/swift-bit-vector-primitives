import Property_Primitives

extension Bit.Vector.Dynamic {

    @inlinable
    public var ones: Property<Bit.Vector.Ones, Self>.Inout {
        mutating _read {
            yield Property<Bit.Vector.Ones, Self>.Inout(&self)
        }
    }
}

extension Property.Inout where Tag == Bit.Vector.Ones, Base == Bit.Vector.Dynamic {

    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        let storage = base.value._storage
        let count = base.value._count
        let countInt = Int(clamping: count)
        let bitsPerWord = UInt.bitWidth

        for (wordIndex, var word) in storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * bitsPerWord + bitIndex
                if globalIndex < countInt {
                    body(Bit.Index(_unchecked: Ordinal(UInt(globalIndex))))
                }
                word &= word &- 1
            }
        }
    }
}
