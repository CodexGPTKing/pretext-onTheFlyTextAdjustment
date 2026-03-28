import Foundation

struct Analyzer {
    static func analyze(_ text: String, mode: WhiteSpaceMode) -> [AnalyzedToken] {
        switch mode {
        case .normal:
            return analyzeNormal(text)
        case .preWrap:
            return analyzePreWrap(text)
        }
    }

    private static func analyzeNormal(_ text: String) -> [AnalyzedToken] {
        var tokens: [AnalyzedToken] = []
        var buffer = ""
        var inWhitespace = false

        for scalar in text.unicodeScalars {
            if scalar.properties.isWhitespace || scalar == "\n" || scalar == "\r" || scalar == "\t" {
                if !inWhitespace {
                    flushText(&buffer, into: &tokens)
                    inWhitespace = true
                }
                if scalar == "\u{00A0}" || scalar == "\u{202F}" || scalar == "\u{2060}" {
                    flushWhitespace(&buffer, into: &tokens)
                    tokens.append(AnalyzedToken(text: String(scalar), kind: .glue))
                    inWhitespace = false
                } else if scalar == "\u{200B}" {
                    flushWhitespace(&buffer, into: &tokens)
                    tokens.append(AnalyzedToken(text: "", kind: .zeroWidthBreak))
                    inWhitespace = false
                } else {
                    buffer.append(" ")
                }
            } else if scalar == "\u{00AD}" {
                flushText(&buffer, into: &tokens)
                flushWhitespace(&buffer, into: &tokens)
                tokens.append(AnalyzedToken(text: "\u{00AD}", kind: .softHyphen))
                inWhitespace = false
            } else {
                if inWhitespace {
                    flushWhitespace(&buffer, into: &tokens)
                    inWhitespace = false
                }
                buffer.append(String(scalar))
            }
        }

        if inWhitespace {
            flushWhitespace(&buffer, into: &tokens)
        } else {
            flushText(&buffer, into: &tokens)
        }
        return tokens
    }

    private static func analyzePreWrap(_ text: String) -> [AnalyzedToken] {
        var tokens: [AnalyzedToken] = []
        var textBuffer = ""

        for scalar in text.unicodeScalars {
            switch scalar {
            case "\n":
                flushText(&textBuffer, into: &tokens)
                tokens.append(AnalyzedToken(text: "\n", kind: .hardBreak))
            case "\t":
                flushText(&textBuffer, into: &tokens)
                tokens.append(AnalyzedToken(text: "\t", kind: .tab))
            case " ":
                flushText(&textBuffer, into: &tokens)
                tokens.append(AnalyzedToken(text: " ", kind: .preservedSpace))
            case "\u{00A0}", "\u{202F}", "\u{2060}":
                flushText(&textBuffer, into: &tokens)
                tokens.append(AnalyzedToken(text: String(scalar), kind: .glue))
            case "\u{200B}":
                flushText(&textBuffer, into: &tokens)
                tokens.append(AnalyzedToken(text: "", kind: .zeroWidthBreak))
            case "\u{00AD}":
                flushText(&textBuffer, into: &tokens)
                tokens.append(AnalyzedToken(text: "\u{00AD}", kind: .softHyphen))
            default:
                textBuffer.append(String(scalar))
            }
        }

        flushText(&textBuffer, into: &tokens)
        return tokens
    }

    private static func flushText(_ buffer: inout String, into tokens: inout [AnalyzedToken]) {
        guard !buffer.isEmpty else { return }
        tokens.append(AnalyzedToken(text: buffer, kind: .text))
        buffer.removeAll(keepingCapacity: true)
    }

    private static func flushWhitespace(_ buffer: inout String, into tokens: inout [AnalyzedToken]) {
        guard !buffer.isEmpty else { return }
        tokens.append(AnalyzedToken(text: " ", kind: .space))
        buffer.removeAll(keepingCapacity: true)
    }
}

struct AnalyzedToken {
    let text: String
    let kind: SegmentBreakKind
}
