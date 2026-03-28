import Foundation

public protocol TextLayoutPreparing: Sendable {
    func prepare(text: String, fontDescriptor: String, options: PreparationOptions) async -> PreparedText
}

public protocol TextLayouting: Sendable {
    func layout(prepared: PreparedText, maxWidth: Double, lineHeight: Double) -> LayoutResult
    func layoutWithLines(prepared: PreparedText, maxWidth: Double, lineHeight: Double) -> LayoutLinesResult
}

public struct TextLayoutEngine: TextLayoutPreparing, TextLayouting, Sendable {
    private let measurer: any TextMeasuring
    private let cache: SegmentWidthCache

    public init(measurer: any TextMeasuring = MonospaceTextMeasurer(), cache: SegmentWidthCache = SegmentWidthCache()) {
        self.measurer = measurer
        self.cache = cache
    }

    public func prepare(text: String, fontDescriptor: String, options: PreparationOptions = .init()) async -> PreparedText {
        let segmented = TextSegmenter.segment(text, mode: options.whiteSpaceMode)
        var preparedSegments: [PreparedSegment] = []
        preparedSegments.reserveCapacity(segmented.count)

        for (segmentText, kind) in segmented {
            let segmentWidth = await measuredWidth(for: segmentText, fontDescriptor: fontDescriptor)
            let graphemeWidths = await graphemeWidths(for: segmentText, fontDescriptor: fontDescriptor)
            preparedSegments.append(
                PreparedSegment(content: segmentText, kind: kind, width: segmentWidth, graphemeWidths: graphemeWidths)
            )
        }

        return PreparedText(source: text, font: fontDescriptor, options: options, segments: preparedSegments)
    }

    public func layout(prepared: PreparedText, maxWidth: Double, lineHeight: Double) -> LayoutResult {
        let lines = computeLines(from: prepared, maxWidth: maxWidth)
        return LayoutResult(lineCount: lines.count, height: Double(lines.count) * lineHeight)
    }

    public func layoutWithLines(prepared: PreparedText, maxWidth: Double, lineHeight: Double) -> LayoutLinesResult {
        let lines = computeLines(from: prepared, maxWidth: maxWidth)
        return LayoutLinesResult(
            lineCount: lines.count,
            height: Double(lines.count) * lineHeight,
            lines: lines
        )
    }

    private func measuredWidth(for segment: String, fontDescriptor: String) async -> Double {
        if let cached = await cache.width(for: segment, fontDescriptor: fontDescriptor) {
            return cached
        }

        let width = measurer.measureWidth(of: segment, fontDescriptor: fontDescriptor)
        await cache.store(width: width, for: segment, fontDescriptor: fontDescriptor)
        return width
    }

    private func graphemeWidths(for segment: String, fontDescriptor: String) async -> [Double] {
        segment.map { grapheme in
            let value = String(grapheme)
            return measurer.measureWidth(of: value, fontDescriptor: fontDescriptor)
        }
    }

    private func computeLines(from prepared: PreparedText, maxWidth: Double) -> [LayoutLine] {
        guard prepared.segments.isEmpty == false else {
            return [LayoutLine(text: "", width: 0, start: .init(segmentIndex: 0, graphemeIndex: 0), end: .init(segmentIndex: 0, graphemeIndex: 0))]
        }

        var lines: [LayoutLine] = []
        var currentLineText = ""
        var currentLineWidth = 0.0
        var currentStart = LayoutCursor(segmentIndex: 0, graphemeIndex: 0)

        for (index, segment) in prepared.segments.enumerated() {
            if segment.kind == .hardBreak {
                lines.append(
                    LayoutLine(
                        text: currentLineText,
                        width: currentLineWidth,
                        start: currentStart,
                        end: .init(segmentIndex: index, graphemeIndex: 0)
                    )
                )
                currentLineText = ""
                currentLineWidth = 0
                currentStart = .init(segmentIndex: index + 1, graphemeIndex: 0)
                continue
            }

            let projectedWidth = currentLineWidth + segment.width
            if projectedWidth <= maxWidth || currentLineText.isEmpty {
                currentLineText += segment.content
                currentLineWidth = projectedWidth
                continue
            }

            lines.append(
                LayoutLine(
                    text: currentLineText,
                    width: currentLineWidth,
                    start: currentStart,
                    end: .init(segmentIndex: index, graphemeIndex: 0)
                )
            )

            if segment.width <= maxWidth {
                currentLineText = segment.content
                currentLineWidth = segment.width
                currentStart = .init(segmentIndex: index, graphemeIndex: 0)
                continue
            }

            let split = breakLongSegment(segment, segmentIndex: index, maxWidth: maxWidth)
            for splitLine in split.dropLast() {
                lines.append(splitLine)
            }
            if let last = split.last {
                currentLineText = last.text
                currentLineWidth = last.width
                currentStart = last.start
            }
        }

        lines.append(
            LayoutLine(
                text: currentLineText,
                width: currentLineWidth,
                start: currentStart,
                end: .init(segmentIndex: prepared.segments.count, graphemeIndex: 0)
            )
        )

        return lines
    }

    private func breakLongSegment(_ segment: PreparedSegment, segmentIndex: Int, maxWidth: Double) -> [LayoutLine] {
        var produced: [LayoutLine] = []
        var run = ""
        var width = 0.0
        var graphemeIndex = 0

        for grapheme in segment.content {
            let graphemeWidth = segment.graphemeWidths.indices.contains(graphemeIndex)
                ? segment.graphemeWidths[graphemeIndex]
                : 0
            let projected = width + graphemeWidth

            if projected <= maxWidth || run.isEmpty {
                run.append(grapheme)
                width = projected
                graphemeIndex += 1
                continue
            }

            produced.append(
                LayoutLine(
                    text: run,
                    width: width,
                    start: .init(segmentIndex: segmentIndex, graphemeIndex: graphemeIndex - run.count),
                    end: .init(segmentIndex: segmentIndex, graphemeIndex: graphemeIndex)
                )
            )
            run = String(grapheme)
            width = graphemeWidth
            graphemeIndex += 1
        }

        if run.isEmpty == false {
            produced.append(
                LayoutLine(
                    text: run,
                    width: width,
                    start: .init(segmentIndex: segmentIndex, graphemeIndex: graphemeIndex - run.count),
                    end: .init(segmentIndex: segmentIndex, graphemeIndex: graphemeIndex)
                )
            )
        }

        return produced
    }
}
