import Foundation

/// Describes a single API endpoint.
///
/// ```swift
/// extension Endpoint {
///     static func user(id: Int) -> Endpoint {
///         Endpoint(path: "/users/\(id)")
///     }
///
///     static func createPost(_ body: NewPost) throws -> Endpoint {
///         try Endpoint(path: "/posts", method: .post, body: .encodable(body))
///     }
/// }
/// ```
public struct Endpoint: Sendable {
    public enum Body: Sendable {
        case data(Data, contentType: String)

        public static func encodable<T: Encodable>(
            _ value: T,
            encoder: JSONEncoder = JSONEncoder()
        ) throws -> Body {
            .data(try encoder.encode(value), contentType: "application/json")
        }

        public static func json(_ object: [String: Any]) throws -> Body {
            .data(
                try JSONSerialization.data(withJSONObject: object),
                contentType: "application/json"
            )
        }
    }

    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem]
    public var headers: [String: String]
    public var body: Body?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Body? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    /// Builds a `URLRequest` against the given base URL.
    public func urlRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        ) else { throw NetworkError.invalidURL }

        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if case let .data(data, contentType) = body {
            request.httpBody = data
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}
