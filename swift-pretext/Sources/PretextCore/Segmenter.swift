import Foundation

struct TextSegmenter {
    static func segment(_ input: String, mode: WhiteSpaceMode) -> [(String, PreparedSegment.Kind)] {
        guard input.isEmpty == false else { return [] }

        return switch mode {
        case .normal: segmentNormal(input)
        case .preWrap: segmentPreWrap(input)
        }
    }

    private static func segmentNormal(_ input: String) -> [(String, PreparedSegment.Kind)] {
        var segments: [(String, PreparedSegment.Kind)] = []
        var buffer = ""
        var activeKind: PreparedSegment.Kind?

        for scalar in input.unicodeScalars {
            let nextKind: PreparedSegment.Kind = scalar.properties.isWhitespace ? .whitespace : .word
            if activeKind == nil || activeKind == nextKind {
                buffer.unicodeScalars.append(scalar)
                activeKind = nextKind
            } else {
                if let activeKind {
                    segments.append((buffer, activeKind))
                }
                buffer = String(scalar)
                activeKind = nextKind
            }
        }

        if let activeKind, buffer.isEmpty == false {
            segments.append((buffer, activeKind))
        }

        return collapseWhitespaceSegments(segments)
    }

    private static func collapseWhitespaceSegments(
        _ raw: [(String, PreparedSegment.Kind)]
    ) -> [(String, PreparedSegment.Kind)] {
        raw.compactMap { segment, kind in
            guard kind == .whitespace else { return (segment, kind) }
            return (" ", .whitespace)
        }
    }

    private static func segmentPreWrap(_ input: String) -> [(String, PreparedSegment.Kind)] {
        var segments: [(String, PreparedSegment.Kind)] = []
        var run = ""

        func flushWordRun() {
            guard run.isEmpty == false else { return }
            segments.append((run, .word))
            run.removeAll(keepingCapacity: true)
        }

        for character in input {
            switch character {
            case "\n":
                flushWordRun()
                segments.append(("\n", .hardBreak))
            case " ", "\t":
                flushWordRun()
                segments.append((String(character), .whitespace))
            default:
                run.append(character)
            }
        }

        flushWordRun()
        return segments
    }
}
