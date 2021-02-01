import XCTest
@testable import NASA

class CategoryCellTests: XCTestCase {

    private let subject = CategoryCell(frame: .zero)

    func testRenderImageCell() {
        subject.render(item: .image)
        XCTAssertEqual(subject.titleLabel.text, MediaType.image.title)
    }

    func testRenderVideoCell() {
        subject.render(item: .video)
        XCTAssertEqual(subject.titleLabel.text, MediaType.video.title)
    }

}
