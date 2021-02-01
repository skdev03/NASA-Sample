import Foundation

enum APIError: Error, Equatable {
    case parsing(description: String)
    case failure(description: String)
    case networkNotReachable

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.parsing(let first), .parsing(let second)):
            return first == second
        case (.failure(let first), .failure(let second)):
            return first == second
        default: return lhs == rhs
        }
    }
}
