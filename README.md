# PretextSwift

Ground-up Swift 6 rewrite of the original Pretext text-layout engine, designed for UIKit and SwiftUI apps and ready to drop into modern iOS projects.

## Goals

- Two-phase architecture for performance:
  - `prepare(...)` does one-time segmentation and measurement.
  - `layout(...)` / `layoutWithLines(...)` perform fast arithmetic-only reflow for width changes.
- Designed for reusable app integration:
  - Pure library API for service-layer use.
  - `PretextLayoutModel` for SwiftUI workflows.
- Whitespace modes:
  - `.normal`: CSS-like collapsing behavior.
  - `.preWrap`: preserves ordinary spaces, tabs, and hard breaks.

## Package Installation

Use Swift Package Manager and point to this repository.

```swift
.package(url: "https://github.com/your-org/pretext-onTheFlyTextAdjustment", branch: "main")
```

Then add:

```swift
.product(name: "PretextSwift", package: "pretext-onTheFlyTextAdjustment")
```

## Quick Start

```swift
import UIKit
import PretextSwift

let prepared = Pretext.prepare(
  "AGI 春天到了. بدأت الرحلة 🚀",
  font: .systemFont(ofSize: 16),
  options: .init(whiteSpace: .normal)
)

let result = Pretext.layout(prepared, maxWidth: 280, lineHeight: 22)
print(result.lineCount, result.height)
```

### Preserving user-entered whitespace

```swift
let prepared = Pretext.prepare(
  textareaText,
  font: .monospacedSystemFont(ofSize: 16, weight: .regular),
  options: .init(whiteSpace: .preWrap)
)
```

### Getting per-line text

```swift
let lines = Pretext.layoutWithLines(prepared, maxWidth: 320, lineHeight: 24)
for line in lines.lines {
  print(line.text, line.width)
}
```

### Walking line ranges (without building every line string)

```swift
let count = Pretext.walkLineRanges(prepared, maxWidth: 320) { line in
  // use line.start / line.end cursors for custom rendering
}
print(count)
```

### Streaming line layout for variable widths

```swift
var cursor = LayoutCursor(segmentIndex: 0, graphemeIndex: 0)
while let line = Pretext.layoutNextLine(prepared, start: cursor, maxWidth: widthForCurrentRow) {
  cursor = line.end
}
```

## API

- `Pretext.prepare(_:font:options:) -> PreparedText`
- `Pretext.layout(_:maxWidth:lineHeight:) -> LayoutResult`
- `Pretext.layoutWithLines(_:maxWidth:lineHeight:) -> LayoutLinesResult`
- `Pretext.walkLineRanges(_:maxWidth:onLine:) -> Int`
- `Pretext.layoutNextLine(_:start:maxWidth:) -> LayoutLine?`
- `Pretext.clearCache()`

## SwiftUI Integration

```swift
@StateObject private var model = PretextLayoutModel()

var body: some View {
  GeometryReader { proxy in
    let layout = model.layout(maxWidth: proxy.size.width, lineHeight: 22)
    Text("\(layout.lineCount) lines")
      .frame(height: layout.height)
  }
  .task {
    model.prepare(text: content, font: .systemFont(ofSize: 16))
  }
}
```

## Notes

- This rewrite focuses on iOS-native measurement and layout behavior.
- For production tuning, prefer named fonts and stable typography settings.
- Run tests with `swift test`.
