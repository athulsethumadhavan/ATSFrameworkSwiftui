import Foundation

/// Hook for mutating outgoing requests (auth tokens, common headers)
/// and reacting to responses (token refresh, logging).
public protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func didReceive(response: HTTPURLResponse, data: Data) async throws
}

public extension RequestInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest { request }
    func didReceive(response: HTTPURLResponse, data: Data) async throws {}
}

/// Adds a Bearer token to every request.
public struct BearerTokenInterceptor: RequestInterceptor {
    private let tokenProvider: @Sendable () async -> String?

    public init(tokenProvider: @escaping @Sendable () async -> String?) {
        self.tokenProvider = tokenProvider
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        if let token = await tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

/// Logs requests and responses to the console in DEBUG builds.
public struct LoggingInterceptor: RequestInterceptor {
    public init() {}

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        #if DEBUG
        print("➡️ \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
        #endif
        return request
    }

    public func didReceive(response: HTTPURLResponse, data: Data) async throws {
        #if DEBUG
        print("⬅️ \(response.statusCode) \(response.url?.absoluteString ?? "?") (\(data.count) bytes)")
        #endif
    }
}
