# Bit Vector Primitives Insights

<!--
---
title: Bit Vector Primitives Insights
version: 1.0.0
last_updated: 2026-02-13
applies_to: [swift-bit-vector-primitives]
normative: false
---
-->

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of swift-bit-vector-primitives.
These are not API requirements — they are recorded decisions and patterns that inform
future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[package: swift-bit-vector-primitives]`.

---

## Test Coverage Gap: .ones.first

**Date**: 2026-02-13

**Context**: The `var first: Element?` property became available on `Ones.Static` and `Ones.View` through the `Sequence.Protocol where Self: Copyable` extension in the sequence-primitives stdlib integration layer. `Zeros.Static.first` is exercised by `Storage.Pool.Inline.allocate()`, but the `Ones` counterpart has no test coverage.

The property view form `Sequence.First` (`.first { predicate }`) is available to all conformers including ~Copyable types. The convenience `var first: Element?` is Copyable-only. Both should be tested for `Ones.Static` and `Ones.View`.

**Applies to**: `Ones.Static`, `Ones.View`, `Zeros.Static`, `Zeros.View`
