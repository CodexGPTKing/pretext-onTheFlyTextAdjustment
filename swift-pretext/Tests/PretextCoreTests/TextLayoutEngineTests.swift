import XCTest
@testable import PretextCore

final class TextLayoutEngineTests: XCTestCase {
    func testPrepareAndLayoutReturnsExpectedLineCount() async {
        let engine = TextLayoutEngine(measurer: MonospaceTextMeasurer(averageGraphemeWidth: 10))
        let prepared = await engine.prepare(
            text: "Hello world from swift",
            fontDescriptor: "17px Inter",
            options: .init(whiteSpaceMode: .normal)
        )

        let layout = engine.layout(prepared: prepared, maxWidth: 60, lineHeight: 22)

        XCTAssertEqual(layout.lineCount, 4)
        XCTAssertEqual(layout.height, 88)
    }

    func testPreWrapRespectsHardBreaks() async {
        let engine = TextLayoutEngine(measurer: MonospaceTextMeasurer(averageGraphemeWidth: 12))
        let prepared = await engine.prepare(
            text: "Line A\nLine B",
            fontDescriptor: "17px Inter",
            options: .init(whiteSpaceMode: .preWrap)
        )

        let layout = engine.layoutWithLines(prepared: prepared, maxWidth: 400, lineHeight: 20)

        XCTAssertEqual(layout.lineCount, 2)
        XCTAssertEqual(layout.lines.map(\.text), ["Line A", "Line B"])
    }
}
