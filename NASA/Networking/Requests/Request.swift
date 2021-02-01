import Foundation

public enum Method: String {
    case get = "GET"
    case post = "POST"
}

public protocol Request {
    associatedtype Response: Decodable

    var method: Method { get }
    var body: Data? { get }
    var path: String { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
}

extension Request {
    var method: Method { .get }
    var body: Data? { nil }
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    
    func resolve(relativeTo baseURL: URL) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = path
        urlComponents.queryItems = queryItems.count > 0 ? queryItems : nil

        // This will allow encoding of some special characters.
        if let queryParams  = urlComponents.query,
            let escapedQuery = queryParams.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            urlComponents.percentEncodedQuery = escapedQuery
        }

        // Plus sign characters are not automatically escaped because they have a significant meaning
        // in URL queries. We don't intend to use them for that purpose so we need to manually escape
        // them. https://stackoverflow.com/questions/6855624/plus-sign-in-query-string
        if let encodedQuery = urlComponents.percentEncodedQuery, encodedQuery.contains("+") {
            urlComponents.percentEncodedQuery = encodedQuery.replacingOccurrences(of: "+", with: "%2B")
        }

        guard let url = urlComponents.url else {
            if path.first == "/" {
                fatalError("🛑 Request `resolve` failed: reason unknown.")
            } else {
                fatalError("🛑 Request `resolve` failed: `path` is missing a leading slash.")
            }
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body

        for (field, value) in headers {
            urlRequest.addValue(value, forHTTPHeaderField: field)
        }

        return urlRequest
    }
}
