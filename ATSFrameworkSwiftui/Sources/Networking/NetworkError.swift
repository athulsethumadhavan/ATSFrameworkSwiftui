import Foundation

public enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case requestFailed(underlying: Error)
    case invalidResponse
    case unacceptableStatusCode(Int, data: Data)
    case decodingFailed(underlying: Error)
    case unauthorized
    case noConnection
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL could not be constructed."
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unacceptableStatusCode(let code, _):
            return "Unexpected status code: \(code)."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "You are not authorized. Please sign in again."
        case .noConnection:
            return "No internet connection."
        case .cancelled:
            return "The request was cancelled."
        }
    }
}
