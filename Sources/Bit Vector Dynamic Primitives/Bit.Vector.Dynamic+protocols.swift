extension Bit.Vector.Dynamic: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        guard lhs._storage.count == rhs._storage.count else { return false }
        for i in 0..<lhs._storage.count {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

extension Bit.Vector.Dynamic: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_count)
        hasher.combine(_storage)
    }
}

extension Bit.Vector.Dynamic: CustomStringConvertible {

    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Dynamic(\(bits)\(suffix))"
    }
}
