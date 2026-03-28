import Foundation
import PretextCore

#if canImport(Observation)
import Observation

@MainActor
@Observable
public final class PretextLayoutModel {
    public private(set) var preparedText: PreparedText?
    public private(set) var latestLayout: LayoutLinesResult?

    private let engine: TextLayoutEngine
    private let fontDescriptor: String
    private let lineHeight: Double
    private let options: PreparationOptions

    public init(
        engine: TextLayoutEngine = TextLayoutEngine(),
        fontDescriptor: String,
        lineHeight: Double,
        options: PreparationOptions = .init()
    ) {
        self.engine = engine
        self.fontDescriptor = fontDescriptor
        self.lineHeight = lineHeight
        self.options = options
    }

    public func prepare(text: String) async {
        preparedText = await engine.prepare(text: text, fontDescriptor: fontDescriptor, options: options)
    }

    public func relayout(maxWidth: Double) {
        guard let preparedText else {
            latestLayout = nil
            return
        }

        latestLayout = engine.layoutWithLines(prepared: preparedText, maxWidth: maxWidth, lineHeight: lineHeight)
    }
}
#else
public enum ObservationUnavailable {
    public static let reason = "Observation framework is unavailable on this platform."
}
#endif
