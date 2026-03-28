import Foundation

public enum WhiteSpaceMode: Sendable {
    case normal
    case preWrap
}

public struct PrepareOptions: Sendable {
    public var whiteSpace: WhiteSpaceMode

    public init(whiteSpace: WhiteSpaceMode = .normal) {
        self.whiteSpace = whiteSpace
    }
}

public struct LayoutCursor: Sendable, Equatable {
    public var segmentIndex: Int
    public var graphemeIndex: Int

    public init(segmentIndex: Int, graphemeIndex: Int) {
        self.segmentIndex = segmentIndex
        self.graphemeIndex = graphemeIndex
    }
}

public struct LayoutResult: Sendable, Equatable {
    public var lineCount: Int
    public var height: CGFloat

    public init(lineCount: Int, height: CGFloat) {
        self.lineCount = lineCount
        self.height = height
    }
}

public struct LayoutLineRange: Sendable, Equatable {
    public var width: CGFloat
    public var start: LayoutCursor
    public var end: LayoutCursor

    public init(width: CGFloat, start: LayoutCursor, end: LayoutCursor) {
        self.width = width
        self.start = start
        self.end = end
    }
}

public struct LayoutLine: Sendable, Equatable {
    public var text: String
    public var width: CGFloat
    public var start: LayoutCursor
    public var end: LayoutCursor

    public init(text: String, width: CGFloat, start: LayoutCursor, end: LayoutCursor) {
        self.text = text
        self.width = width
        self.start = start
        self.end = end
    }
}

public struct LayoutLinesResult: Sendable, Equatable {
    public var lineCount: Int
    public var height: CGFloat
    public var lines: [LayoutLine]

    public init(lineCount: Int, height: CGFloat, lines: [LayoutLine]) {
        self.lineCount = lineCount
        self.height = height
        self.lines = lines
    }
}

public enum SegmentBreakKind: Sendable {
    case text
    case space
    case preservedSpace
    case tab
    case glue
    case zeroWidthBreak
    case softHyphen
    case hardBreak
}

public struct Segment: Sendable {
    public let text: String
    public let width: CGFloat
    public let kind: SegmentBreakKind
    public let graphemeWidths: [CGFloat]?

    public init(text: String, width: CGFloat, kind: SegmentBreakKind, graphemeWidths: [CGFloat]?) {
        self.text = text
        self.width = width
        self.kind = kind
        self.graphemeWidths = graphemeWidths
    }
}

public struct PreparedText: Sendable {
    public let font: PretextFont
    public let options: PrepareOptions
    public let segments: [Segment]

    public init(font: PretextFont, options: PrepareOptions, segments: [Segment]) {
        self.font = font
        self.options = options
        self.segments = segments
    }
}
