extension Bit.Vector.Inline: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        for i in 0..<wordCount {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

extension Bit.Vector.Inline: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_count)
        for i in 0..<wordCount {
            hasher.combine(_storage[i])
        }
    }
}

extension Bit.Vector.Inline: CustomStringConvertible {

    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Inline<\(wordCount)>(\(bits)\(suffix))"
    }
}
