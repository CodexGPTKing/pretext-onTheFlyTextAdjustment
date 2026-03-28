import Foundation

public enum WhiteSpaceMode: String, Sendable {
    case normal
    case preWrap
}

public struct PreparationOptions: Sendable, Equatable {
    public var whiteSpaceMode: WhiteSpaceMode

    public init(whiteSpaceMode: WhiteSpaceMode = .normal) {
        self.whiteSpaceMode = whiteSpaceMode
    }
}

public struct LayoutCursor: Hashable, Sendable {
    public let segmentIndex: Int
    public let graphemeIndex: Int

    public init(segmentIndex: Int, graphemeIndex: Int) {
        self.segmentIndex = segmentIndex
        self.graphemeIndex = graphemeIndex
    }
}

public struct LayoutLine: Sendable, Equatable {
    public let text: String
    public let width: Double
    public let start: LayoutCursor
    public let end: LayoutCursor

    public init(text: String, width: Double, start: LayoutCursor, end: LayoutCursor) {
        self.text = text
        self.width = width
        self.start = start
        self.end = end
    }
}

public struct LayoutResult: Sendable, Equatable {
    public let lineCount: Int
    public let height: Double

    public init(lineCount: Int, height: Double) {
        self.lineCount = lineCount
        self.height = height
    }
}

public struct LayoutLinesResult: Sendable, Equatable {
    public let lineCount: Int
    public let height: Double
    public let lines: [LayoutLine]

    public init(lineCount: Int, height: Double, lines: [LayoutLine]) {
        self.lineCount = lineCount
        self.height = height
        self.lines = lines
    }
}

public struct PreparedSegment: Sendable, Equatable {
    public enum Kind: Sendable {
        case word
        case whitespace
        case hardBreak
    }

    public let content: String
    public let kind: Kind
    public let width: Double
    public let graphemeWidths: [Double]

    public init(content: String, kind: Kind, width: Double, graphemeWidths: [Double]) {
        self.content = content
        self.kind = kind
        self.width = width
        self.graphemeWidths = graphemeWidths
    }
}

public struct PreparedText: Sendable, Equatable {
    public let source: String
    public let font: String
    public let options: PreparationOptions
    public let segments: [PreparedSegment]

    public init(source: String, font: String, options: PreparationOptions, segments: [PreparedSegment]) {
        self.source = source
        self.font = font
        self.options = options
        self.segments = segments
    }
}
