import Foundation

public enum NetworkError: LocalizedError, Sendable, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(String)
    case maxRetriesExceeded
    case underlying(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .invalidResponse:
            return "The server response was unexpected or invalid."
        case .httpError(let code, _):
            return "HTTP request failed with status code \(code)."
        case .decodingError(let msg):
            return "Failed to decode response: \(msg)"
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded."
        case .underlying(let msg):
            return msg
        }
    }
}

public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let initialDelay: TimeInterval
    public let multiplier: Double

    public static let standard = RetryPolicy(maxAttempts: 3, initialDelay: 0.5, multiplier: 2.0)
    public static let none = RetryPolicy(maxAttempts: 1, initialDelay: 0, multiplier: 1.0)

    public init(maxAttempts: Int = 3, initialDelay: TimeInterval = 0.5, multiplier: Double = 2.0) {
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.multiplier = multiplier
    }
}
