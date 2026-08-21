import Property_Primitives

extension Bit.Vector.Dynamic {

    @inlinable
    public var zeros: Property<Bit.Vector.Zeros, Self>.Inout {
        mutating _read {
            yield Property<Bit.Vector.Zeros, Self>.Inout(&self)
        }
    }
}

extension Property.Inout where Tag == Bit.Vector.Zeros, Base == Bit.Vector.Dynamic {

    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        let storage = base.value._storage
        let count = base.value._count
        let countInt = Int(clamping: count)
        let bitsPerWord = UInt.bitWidth

        for (wordIndex, word) in storage.enumerated() {
            var inverted = ~word
            while inverted != 0 {
                let bitIndex = inverted.trailingZeroBitCount
                let globalIndex = wordIndex * bitsPerWord + bitIndex
                if globalIndex < countInt {
                    body(Bit.Index(_unchecked: Ordinal(UInt(globalIndex))))
                }
                inverted &= inverted &- 1
            }
        }
    }
}
