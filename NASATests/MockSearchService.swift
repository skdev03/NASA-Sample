import Foundation
import Combine
@testable import NASA

class MockSearchService: SearchService {
    var result: AnyPublisher<[Item], APIError>!

    func search(searchTerm: String, mediaType: String) -> AnyPublisher<[Item], APIError> {
        return result
    }
}
