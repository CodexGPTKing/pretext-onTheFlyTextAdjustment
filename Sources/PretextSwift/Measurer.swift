import Foundation
#if canImport(UIKit)
import UIKit
#endif

final class SegmentMeasurer: @unchecked Sendable {
    static let shared = SegmentMeasurer()

    private var widthCache: [String: CGFloat] = [:]
    private let lock = NSLock()

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        widthCache.removeAll(keepingCapacity: true)
    }

    func measure(text: String, font: PretextFont) -> CGFloat {
        if text.isEmpty { return 0 }
        let key = "\(font.fontName)|\(font.pointSize)|\(text)"

        lock.lock()
        if let cached = widthCache[key] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        let width: CGFloat
        #if canImport(UIKit)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        width = (text as NSString).size(withAttributes: attrs).width
        #else
        width = CGFloat(text.count) * font.pointSize * 0.55
        #endif

        lock.lock()
        widthCache[key] = width
        lock.unlock()

        return width
    }

    func graphemeWidths(text: String, font: PretextFont) -> [CGFloat] {
        text.map { grapheme in
            measure(text: String(grapheme), font: font)
        }
    }
}
