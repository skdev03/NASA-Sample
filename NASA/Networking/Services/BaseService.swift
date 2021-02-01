import Foundation
import Combine

public class BaseService {
    private let session: URLSession
    private let baseURL: URL? = URL(string: "https://images-api.nasa.gov/")
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func execute<R: Request>(request: R,
                             decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<R.Response, Error> {
        guard let baseURL = baseURL else { preconditionFailure("Provide a base URL") }
        
        return session.dataTaskPublisher(for: request.resolve(relativeTo: baseURL))
            .tryMap {
                guard let response = $0.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw APIError.failure(description: "")
                }

                return $0.data
            }
            .decode(type: R.Response.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
