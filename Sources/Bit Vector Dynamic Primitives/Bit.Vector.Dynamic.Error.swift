public enum __BitVectorDynamicError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case invalidCount
}
