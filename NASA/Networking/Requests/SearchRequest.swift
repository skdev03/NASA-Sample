import Foundation

struct SearchRequest: Request {
    typealias Response = SearchResponse
    
    var path: String { "/search" }
    
    let queryItems: [URLQueryItem]
    
    init(searchTerm: String, mediaType: String) {
        queryItems = [
            URLQueryItem(name: "q", value: searchTerm),
            URLQueryItem(name: "media_type", value: mediaType)
        ]
    }
}
