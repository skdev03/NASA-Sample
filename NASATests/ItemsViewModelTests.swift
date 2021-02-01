import XCTest
import Combine
@testable import NASA

class ItemsViewModelTests: XCTestCase {

    private var subject: ItemsViewModel!
    private let service = MockSearchService()
    private var userDefaults: MockUserDefaults!
    private var persistenceManager: PersistenceManager!

    override func setUp() {
        super.setUp()

        userDefaults = MockUserDefaults()
        persistenceManager = PersistenceManager(userDefaults: userDefaults)
    }

    func testImageItems() throws {
        subject = ItemsViewModel(service: service, mediaType: .image, persistenceManager: persistenceManager)

        let items = [Item(links: nil, href: "href1", data: []), Item(links: nil, href: "href2", data: [])]
        service.result = mockResponsePublisher(items)
        let result = expectValue(of: subject.$items, expectedValue: items)
        subject.searchTerm = "apollo"
        waitForExpectation(result.expectation)
    }

    func testError() throws {
        subject = ItemsViewModel(service: service, mediaType: .image, persistenceManager: persistenceManager)

        let error = APIError.failure(description: "Network unreachable")
        service.result = mockErrorPublisher(error)

        let result = expectValue(of: subject.$error, expectedValue: error)
        subject.searchTerm = "apollo"
        waitForExpectation(result.expectation)
    }

    func testFavorites() {
        let item = Item(links: nil, href: "href1", data: [])
        subject = ItemsViewModel(service: service, mediaType: .image, persistenceManager: persistenceManager)

        XCTAssertFalse(isItemSaved(item))

        subject.toggleFavorite(for: item)
        XCTAssert(isItemSaved(item))

        subject.toggleFavorite(for: item)
        XCTAssertFalse(isItemSaved(item))
    }

    private func isItemSaved(_ item: Item) -> Bool {
        guard let favs = userDefaults.value(forKey: "favoritesKey") as? [Data], let encodedItem = self.encodedItem(item) else {
            return false
        }

        return favs.contains(encodedItem)
    }

    private func encodedItem(_ item: Item) -> Data? {
        return try? JSONEncoder().encode(item)
    }
    
    func mockResponsePublisher(_ items: [Item]) -> AnyPublisher<[Item], APIError> {
        return Just(items)
            .mapError { _  in APIError.failure(description: "Error") }
            .eraseToAnyPublisher()
    }

    func mockErrorPublisher(_ error: APIError) -> AnyPublisher<[Item], APIError> {
        let subject = CurrentValueSubject<[Item], APIError>([])
        subject.send(completion: .failure(error))
        return subject.eraseToAnyPublisher()
    }
}

extension XCTestCase {
    typealias PublisherCompletion = (expectation: XCTestExpectation, subscription: AnyCancellable)

    func waitForExpectation(_ expectation: XCTestExpectation, timeout: TimeInterval = 2.0) {
        wait(for: [expectation], timeout: timeout)
    }

    func expectCompletion<T: Publisher>(of publisher: T,
                                        timeout: TimeInterval = 2) -> PublisherCompletion {
        let completionExpectation = expectation(description: String(describing: publisher) + "completed")

        let subscription = publisher
            .sink(receiveCompletion: { completion in
                if case .finished = completion { completionExpectation.fulfill() }
            }, receiveValue: { _ in })

        return (completionExpectation, subscription)
    }

    func expectValue<T: Publisher>(of publisher: T,
                                   timeout: TimeInterval = 2,
                                   expectedValue: T.Output) -> PublisherCompletion where T.Output: Equatable {
        let completionExpectation = expectation(description: String(describing: publisher) + "received a value")

        let subscription = publisher
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                if value == expectedValue { completionExpectation.fulfill() }
            })

        return (completionExpectation, subscription)
    }
}



