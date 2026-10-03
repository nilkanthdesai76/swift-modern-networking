import Foundation

public actor NetworkClient {
    private let session: URLSession
    private let interceptors: [RequestInterceptor]
    private let decoder: JSONDecoder

    public init(
        session: URLSession = .shared,
        interceptors: [RequestInterceptor] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.interceptors = interceptors
        self.decoder = decoder
    }

    /// Executes an HTTP request with automatic retry policy and decodes the response model.
    public func send<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        retryPolicy: RetryPolicy = .standard
    ) async throws -> T {
        let (data, _) = try await execute(endpoint, retryPolicy: retryPolicy)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    /// Executes an HTTP request and returns raw Data and HTTPURLResponse.
    public func execute(
        _ endpoint: Endpoint,
        retryPolicy: RetryPolicy = .standard
    ) async throws -> (Data, HTTPURLResponse) {
        var request = try endpoint.makeURLRequest()

        for interceptor in interceptors {
            try await interceptor.intercept(&request)
        }

        var attempt = 0
        var currentDelay = retryPolicy.initialDelay

        while attempt < retryPolicy.maxAttempts {
            attempt += 1
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if (500...599).contains(httpResponse.statusCode) && attempt < retryPolicy.maxAttempts {
                        try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                        currentDelay *= retryPolicy.multiplier
                        continue
                    }
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                }

                return (data, httpResponse)
            } catch let error as NetworkError {
                throw error
            } catch {
                if attempt >= retryPolicy.maxAttempts {
                    throw NetworkError.underlying(error.localizedDescription)
                }
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                currentDelay *= retryPolicy.multiplier
            }
        }

        throw NetworkError.maxRetriesExceeded
    }
}
