# PretextSwift

A pure-Swift 6 rewrite of Pretext's core prepare/layout flow, designed to integrate cleanly into modern iOS SwiftUI app architectures.

## Highlights

- Protocol-oriented (`TextLayoutPreparing`, `TextLayouting`, `TextMeasuring`)
- Actor-backed width cache (`SegmentWidthCache`) for concurrency safety
- Async preparation (`prepare`) and pure arithmetic layout pass (`layout`, `layoutWithLines`)
- Optional `@Observable` SwiftUI adapter (`PretextLayoutModel`) behind `canImport(Observation)`

## Quick start

```swift
let engine = TextLayoutEngine()
let prepared = await engine.prepare(text: "Hello", fontDescriptor: "17px Inter", options: .init())
let result = engine.layout(prepared: prepared, maxWidth: 200, lineHeight: 22)
```
