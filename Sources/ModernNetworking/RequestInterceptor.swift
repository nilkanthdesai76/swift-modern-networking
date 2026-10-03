import Foundation

/// Protocol for intercepting outgoing network requests and adapting them (e.g. injecting auth tokens, API keys, tracing headers).
public protocol RequestInterceptor: Sendable {
    /// Intercepts and mutates an outgoing URLRequest before transmission.
    func intercept(_ request: inout URLRequest) async throws
}

/// Convenience interceptor that automatically attaches standard HTTP headers (like User-Agent, Accept, or custom headers).
public struct HeaderInterceptor: RequestInterceptor, Sendable {
    public let headers: [String: String]

    public init(headers: [String: String]) {
        self.headers = headers
    }

    public func intercept(_ request: inout URLRequest) async throws {
        for (key, value) in headers {
            if request.value(forHTTPHeaderField: key) == nil {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
}
