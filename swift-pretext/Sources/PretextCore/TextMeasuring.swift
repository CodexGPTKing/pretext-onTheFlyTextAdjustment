import Foundation

public protocol TextMeasuring: Sendable {
    func measureWidth(of text: String, fontDescriptor: String) -> Double
}

public struct MonospaceTextMeasurer: TextMeasuring {
    public let averageGraphemeWidth: Double

    public init(averageGraphemeWidth: Double = 8) {
        self.averageGraphemeWidth = averageGraphemeWidth
    }

    public func measureWidth(of text: String, fontDescriptor: String) -> Double {
        let graphemeCount = text.count
        return Double(graphemeCount) * averageGraphemeWidth
    }
}

public actor SegmentWidthCache {
    private var storage: [String: [String: Double]] = [:]

    public init() {}

    public func width(for segment: String, fontDescriptor: String) -> Double? {
        storage[fontDescriptor]?[segment]
    }

    public func store(width: Double, for segment: String, fontDescriptor: String) {
        var fontBucket = storage[fontDescriptor, default: [:]]
        fontBucket[segment] = width
        storage[fontDescriptor] = fontBucket
    }

    public func clear() {
        storage.removeAll(keepingCapacity: false)
    }
}
