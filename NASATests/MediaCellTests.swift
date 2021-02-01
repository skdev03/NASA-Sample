import XCTest
@testable import NASA

class MediaCellTests: XCTestCase {

    private let subject = MediaCell(frame: .zero)

    func testRenderCell() {
        let link = Link(href: "https://image.link.com", render: nil, rel: "preview")
        let itemTitle = "Apollo 11 Launch"
        let itemData = ItemData(nasaID: "nasaId", album: nil, keywords: nil, center: "", dateCreated: Date(), description: nil, mediaType: .image, title: itemTitle, photographer: nil, location: nil)
        let item = Item(links: [link], href: "href1", data: [itemData])
        subject.render(item: item)
        XCTAssertEqual(subject.titleLabel.text, itemTitle)
    }

}
