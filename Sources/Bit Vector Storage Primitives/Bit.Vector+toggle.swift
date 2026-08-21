extension Bit.Vector {

    @inlinable
    public nonmutating func toggle(_ index: Bit.Index) {
        precondition(index < capacity, "Index out of bounds")
        let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
        let current = unsafe _words[location.word]
        unsafe _words[location.word] = current ^ location.mask
    }
}
