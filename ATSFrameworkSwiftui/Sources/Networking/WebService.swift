import Foundation

/// Abstraction over the network layer — inject a mock in tests.
public protocol WebServiceProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func requestData(_ endpoint: Endpoint) async throws -> Data
    func requestVoid(_ endpoint: Endpoint) async throws
}

/// URLSession-backed async/await web service.
///
/// ```swift
/// let service = WebService(
///     baseURL: URL(string: "https://api.example.com")!,
///     interceptors: [BearerTokenInterceptor { await Auth.token }, LoggingInterceptor()]
/// )
/// let user: User = try await service.request(.user(id: 1), as: User.self)
/// ```
public final class WebService: WebServiceProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let interceptors: [RequestInterceptor]

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = {
            let d = JSONDecoder()
            d.keyDecodingStrategy = .convertFromSnakeCase
            d.dateDecodingStrategy = .iso8601
            return d
        }(),
        interceptors: [RequestInterceptor] = []
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.interceptors = interceptors
    }

    public func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as type: T.Type = T.self
    ) async throws -> T {
        let data = try await requestData(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }

    public func requestVoid(_ endpoint: Endpoint) async throws {
        _ = try await requestData(endpoint)
    }

    public func requestData(_ endpoint: Endpoint) async throws -> Data {
        var request = try endpoint.urlRequest(baseURL: baseURL)
        for interceptor in interceptors {
            request = try await interceptor.adapt(request)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkError.cancelled
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noConnection
        } catch {
            throw NetworkError.requestFailed(underlying: error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        for interceptor in interceptors {
            try await interceptor.didReceive(response: http, data: data)
        }

        switch http.statusCode {
        case 200...299:
            return data
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.unacceptableStatusCode(http.statusCode, data: data)
        }
    }
}
