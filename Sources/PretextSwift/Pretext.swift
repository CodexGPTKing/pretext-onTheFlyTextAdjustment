import Foundation

public enum Pretext {
    public static func prepare(_ text: String, font: PretextFont, options: PrepareOptions = .init()) -> PreparedText {
        let analyzed = Analyzer.analyze(text, mode: options.whiteSpace)
        let measured = analyzed.map { token -> Segment in
            let width: CGFloat
            switch token.kind {
            case .tab:
                let spaceWidth = SegmentMeasurer.shared.measure(text: " ", font: font)
                width = spaceWidth * 8
            case .softHyphen, .hardBreak, .zeroWidthBreak:
                width = 0
            default:
                width = SegmentMeasurer.shared.measure(text: token.text, font: font)
            }

            let graphemeWidths: [CGFloat]?
            if token.kind == .text || token.kind == .glue {
                graphemeWidths = SegmentMeasurer.shared.graphemeWidths(text: token.text, font: font)
            } else {
                graphemeWidths = nil
            }

            return Segment(text: token.text, width: width, kind: token.kind, graphemeWidths: graphemeWidths)
        }

        return PreparedText(font: font, options: options, segments: measured)
    }

    public static func layout(_ prepared: PreparedText, maxWidth: CGFloat, lineHeight: CGFloat) -> LayoutResult {
        let ranges = LineBreaker.breakLines(prepared: prepared, maxWidth: maxWidth)
        return LayoutResult(lineCount: ranges.count, height: CGFloat(ranges.count) * lineHeight)
    }

    public static func layoutWithLines(_ prepared: PreparedText, maxWidth: CGFloat, lineHeight: CGFloat) -> LayoutLinesResult {
        let ranges = LineBreaker.breakLines(prepared: prepared, maxWidth: maxWidth)
        let lines = ranges.map { range in
            let text = materializeText(prepared: prepared, range: range)
            return LayoutLine(text: text, width: range.width, start: range.start, end: range.end)
        }

        return LayoutLinesResult(lineCount: lines.count, height: CGFloat(lines.count) * lineHeight, lines: lines)
    }

    @discardableResult
    public static func walkLineRanges(
        _ prepared: PreparedText,
        maxWidth: CGFloat,
        onLine: (LayoutLineRange) -> Void
    ) -> Int {
        let ranges = LineBreaker.breakLines(prepared: prepared, maxWidth: maxWidth)
        for range in ranges {
            onLine(range)
        }
        return ranges.count
    }

    public static func layoutNextLine(
        _ prepared: PreparedText,
        start: LayoutCursor,
        maxWidth: CGFloat
    ) -> LayoutLine? {
        let range = LineBreaker.nextLine(prepared: prepared, start: start, maxWidth: maxWidth)
        guard let range else { return nil }
        let text = materializeText(prepared: prepared, range: range)
        return LayoutLine(text: text, width: range.width, start: range.start, end: range.end)
    }

    public static func clearCache() {
        SegmentMeasurer.shared.clear()
    }

    private static func materializeText(prepared: PreparedText, range: LayoutLineRange) -> String {
        guard !prepared.segments.isEmpty else { return "" }
        var output = ""
        for index in range.start.segmentIndex..<range.end.segmentIndex {
            output += prepared.segments[index].text
        }
        return output.replacingOccurrences(of: "\u{00AD}", with: "")
    }
}
