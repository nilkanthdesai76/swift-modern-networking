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

    func testRetryPolicyInitialization() {
        let policy = RetryPolicy.standard
        XCTAssertEqual(policy.maxAttempts, 3)
        XCTAssertEqual(policy.initialDelay, 0.5)
    }

    func testNetworkErrorDescriptions() {
        let error = NetworkError.httpError(statusCode: 404, data: nil)
        XCTAssertEqual(error.errorDescription, "HTTP request failed with status code 404.")
    }
}
