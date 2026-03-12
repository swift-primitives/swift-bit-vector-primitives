# Experiments Index

Experiments for swift-bit-vector-primitives.

## Experiments

| Directory | Purpose | Date | Toolchain | Status |
|-----------|---------|------|-----------|--------|
| sequence-protocol-conformance | Validate Sequence.Protocol + Swift.Sequence conformance for ones iteration | 2026-02-06 | swift-DEVELOPMENT-SNAPSHOT-2026-01-18-a | CONFIRMED |
| bit-vector-protocol | Validate ~Copyable protocol for unifying popcount/ones/popFirst/clearAll/setAll across all Bit.Vector variants | 2026-02-12 | Apple Swift 6.2.3 | CONFIRMED |
| property-view-protocol-constraint | Validate Property.View extensions with protocol constraints (Base: Protocol & ~Copyable) instead of concrete type constraints | 2026-02-12 | swift-DEVELOPMENT-SNAPSHOT-2026-02-11-a | CONFIRMED |
| iterator-struct-storage | Validate bitmap iterator works when stored as struct property (all 9 variants pass — original failure was stale build artifact) | 2026-02-24 | swift-DEVELOPMENT-SNAPSHOT-2026-02-21-a | CONFIRMED (stale build) |
