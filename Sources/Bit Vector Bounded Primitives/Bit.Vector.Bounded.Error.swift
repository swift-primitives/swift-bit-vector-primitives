public enum __BitVectorBoundedError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case invalidCount
    case overflow
}
