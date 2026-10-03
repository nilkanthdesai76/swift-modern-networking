import XCTest
@testable import ModernNetworking

struct MockEndpoint: Endpoint {
    var baseURL: URL { URL(string: "https://api.example.com")! }
    var path: String { "test" }
    var method: HTTPMethod { .get }
    var headers: [String : String]? { ["X-Test": "Value"] }
    var queryItems: [URLQueryItem]? { [URLQueryItem(name: "q", value: "swift")] }
    var body: Data? { nil }
}

final class ModernNetworkingTests: XCTestCase {
    func testEndpointMakeURLRequest() throws {
        let endpoint = MockEndpoint()
        let request = try endpoint.makeURLRequest()

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/test?q=swift")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "Value")
    }

    func testHeaderInterceptor() async throws {
        let interceptor = HeaderInterceptor(headers: [
            "Authorization": "Bearer secret-token",
            "User-Agent": "SwiftModernNetworking/1.0"
        ])

        let endpoint = MockEndpoint()
        var request = try endpoint.makeURLRequest()
        try await interceptor.intercept(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer secret-token")
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), "SwiftModernNetworking/1.0")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "Value")
    }

    func testRetryPolicyInitialization() {
        let policy = RetryPolicy.standard
        XCTAssertEqual(policy.maxAttempts, 3)
        XCTAssertEqual(policy.initialDelay, 0.5)
        XCTAssertEqual(policy.multiplier, 2.0)
    }

    func testNetworkErrorDescriptions() {
        let error = NetworkError.httpError(statusCode: 404, data: nil)
        XCTAssertEqual(error.errorDescription, "HTTP request failed with status code 404.")

        let invalid = NetworkError.invalidURL
        XCTAssertEqual(invalid.errorDescription, "The requested URL is invalid.")
    }
}
