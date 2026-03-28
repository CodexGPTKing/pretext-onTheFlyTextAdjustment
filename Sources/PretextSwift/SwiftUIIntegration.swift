#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class PretextLayoutModel: ObservableObject {
    @Published public private(set) var prepared: PreparedText?

    public init() {}

    public func prepare(text: String, font: PretextFont, options: PrepareOptions = .init()) {
        prepared = Pretext.prepare(text, font: font, options: options)
    }

    public func layout(maxWidth: CGFloat, lineHeight: CGFloat) -> LayoutResult {
        guard let prepared else { return LayoutResult(lineCount: 0, height: 0) }
        return Pretext.layout(prepared, maxWidth: maxWidth, lineHeight: lineHeight)
    }

    public func lines(maxWidth: CGFloat, lineHeight: CGFloat) -> LayoutLinesResult {
        guard let prepared else { return LayoutLinesResult(lineCount: 0, height: 0, lines: []) }
        return Pretext.layoutWithLines(prepared, maxWidth: maxWidth, lineHeight: lineHeight)
    }
}
#endif
