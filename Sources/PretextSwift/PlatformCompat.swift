import Foundation

#if !canImport(CoreGraphics)
public typealias CGFloat = Double
#endif

#if canImport(UIKit)
import UIKit
public typealias PretextFont = UIFont
#else
public struct PretextFont: Sendable, Hashable {
    public let pointSize: CGFloat
    public let fontName: String

    public init(fontName: String = "System", pointSize: CGFloat) {
        self.fontName = fontName
        self.pointSize = pointSize
    }

    public static func systemFont(ofSize size: CGFloat) -> PretextFont {
        PretextFont(pointSize: size)
    }

    public static func monospacedSystemFont(ofSize size: CGFloat, weight: Double = 0) -> PretextFont {
        PretextFont(fontName: "Monospace", pointSize: size)
    }
}
#endif
