import XCTest
@testable import PretextSwift

final class PretextSwiftTests: XCTestCase {
    func testLayoutProducesMultipleLinesWhenWidthIsNarrow() {
        let prepared = Pretext.prepare("hello world from pretext", font: .systemFont(ofSize: 18))
        let result = Pretext.layout(prepared, maxWidth: 80, lineHeight: 24)

        XCTAssertGreaterThanOrEqual(result.lineCount, 2)
        XCTAssertEqual(result.height, CGFloat(result.lineCount) * 24)
    }

    func testPreWrapHonorsHardBreaks() {
        let text = "line1\nline2\nline3"
        let prepared = Pretext.prepare(text, font: .systemFont(ofSize: 16), options: .init(whiteSpace: .preWrap))
        let result = Pretext.layout(prepared, maxWidth: 500, lineHeight: 20)

        XCTAssertEqual(result.lineCount, 3)
    }

    func testWalkLineRangesMatchesLayoutWithLinesCount() {
        let prepared = Pretext.prepare("مرحبا hello こんにちは", font: .systemFont(ofSize: 17))
        let lines = Pretext.layoutWithLines(prepared, maxWidth: 120, lineHeight: 22)
        var walked = 0

        let walkedCount = Pretext.walkLineRanges(prepared, maxWidth: 120) { _ in
            walked += 1
        }

        XCTAssertEqual(walked, lines.lineCount)
        XCTAssertEqual(walkedCount, lines.lineCount)
    }
}
