import Foundation
import Combine

protocol SearchService {
    func search(searchTerm: String, mediaType: String) -> AnyPublisher<[Item], APIError>
}

class NASASearchService: BaseService, SearchService {
    func search(searchTerm: String, mediaType: String) -> AnyPublisher<[Item], APIError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
                
        return execute(request: SearchRequest(searchTerm: searchTerm, mediaType: mediaType), decoder: decoder)
            .mapError { .failure(description: $0.localizedDescription) }
            .map { $0.collection.items }
            .eraseToAnyPublisher()
    }
}
