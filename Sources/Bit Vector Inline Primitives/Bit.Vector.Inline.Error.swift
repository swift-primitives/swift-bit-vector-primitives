public enum __BitVectorInlineError: Swift.Error, Sendable, Equatable {
    case bounds(index: Bit.Index, count: Bit.Index.Count)
    case overflow
}
