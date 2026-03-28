import Foundation

enum LineBreaker {
    static func breakLines(prepared: PreparedText, maxWidth: CGFloat) -> [LayoutLineRange] {
        guard !prepared.segments.isEmpty else {
            return [LayoutLineRange(width: 0, start: .init(segmentIndex: 0, graphemeIndex: 0), end: .init(segmentIndex: 0, graphemeIndex: 0))]
        }

        var output: [LayoutLineRange] = []
        var cursor = LayoutCursor(segmentIndex: 0, graphemeIndex: 0)

        while let line = nextLine(prepared: prepared, start: cursor, maxWidth: maxWidth) {
            output.append(line)
            cursor = line.end
            if cursor.segmentIndex >= prepared.segments.count {
                break
            }
        }

        return output.isEmpty ? [LayoutLineRange(width: 0, start: .init(segmentIndex: 0, graphemeIndex: 0), end: .init(segmentIndex: 0, graphemeIndex: 0))] : output
    }

    static func nextLine(prepared: PreparedText, start: LayoutCursor, maxWidth: CGFloat) -> LayoutLineRange? {
        guard start.segmentIndex < prepared.segments.count else { return nil }

        let segments = prepared.segments
        var width: CGFloat = 0
        var index = start.segmentIndex
        var lastBreak = start.segmentIndex
        var sawBreak = false

        while index < segments.count {
            let segment = segments[index]

            if segment.kind == .hardBreak {
                return LayoutLineRange(
                    width: width,
                    start: LayoutCursor(segmentIndex: start.segmentIndex, graphemeIndex: 0),
                    end: LayoutCursor(segmentIndex: index + 1, graphemeIndex: 0)
                )
            }

            if width + segment.width <= maxWidth || width == 0 {
                width += segment.width
                index += 1

                if isBreakOpportunity(segment.kind) {
                    lastBreak = index
                    sawBreak = true
                }
                continue
            }

            if sawBreak && lastBreak > start.segmentIndex {
                let lineWidth = sumWidth(segments[start.segmentIndex..<lastBreak])
                return LayoutLineRange(
                    width: lineWidth,
                    start: LayoutCursor(segmentIndex: start.segmentIndex, graphemeIndex: 0),
                    end: LayoutCursor(segmentIndex: lastBreak, graphemeIndex: 0)
                )
            }

            if let graphemeLine = breakInsideSegment(prepared: prepared, start: start, segmentIndex: index, maxWidth: maxWidth, consumedWidth: width) {
                return graphemeLine
            }

            return LayoutLineRange(
                width: width,
                start: LayoutCursor(segmentIndex: start.segmentIndex, graphemeIndex: 0),
                end: LayoutCursor(segmentIndex: max(start.segmentIndex + 1, index), graphemeIndex: 0)
            )
        }

        return LayoutLineRange(
            width: width,
            start: LayoutCursor(segmentIndex: start.segmentIndex, graphemeIndex: 0),
            end: LayoutCursor(segmentIndex: segments.count, graphemeIndex: 0)
        )
    }

    private static func breakInsideSegment(
        prepared: PreparedText,
        start: LayoutCursor,
        segmentIndex: Int,
        maxWidth: CGFloat,
        consumedWidth: CGFloat
    ) -> LayoutLineRange? {
        let segment = prepared.segments[segmentIndex]
        guard let graphemeWidths = segment.graphemeWidths, !graphemeWidths.isEmpty else { return nil }

        var fitWidth = consumedWidth
        var graphemeCount = 0

        for width in graphemeWidths {
            if fitWidth + width > maxWidth, graphemeCount > 0 {
                break
            }
            fitWidth += width
            graphemeCount += 1
            if fitWidth > maxWidth {
                break
            }
        }

        if graphemeCount == 0 {
            graphemeCount = 1
            fitWidth = consumedWidth + graphemeWidths[0]
        }

        if segmentIndex == start.segmentIndex {
            return LayoutLineRange(
                width: fitWidth,
                start: LayoutCursor(segmentIndex: segmentIndex, graphemeIndex: 0),
                end: LayoutCursor(segmentIndex: segmentIndex + 1, graphemeIndex: graphemeCount)
            )
        }

        return LayoutLineRange(
            width: fitWidth,
            start: LayoutCursor(segmentIndex: start.segmentIndex, graphemeIndex: 0),
            end: LayoutCursor(segmentIndex: segmentIndex + 1, graphemeIndex: graphemeCount)
        )
    }

    private static func isBreakOpportunity(_ kind: SegmentBreakKind) -> Bool {
        switch kind {
        case .space, .preservedSpace, .zeroWidthBreak, .softHyphen:
            return true
        default:
            return false
        }
    }

    private static func sumWidth(_ slice: ArraySlice<Segment>) -> CGFloat {
        slice.reduce(0) { $0 + $1.width }
    }
}
