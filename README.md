# ModernNetworking 🌐

A modern, type-safe HTTP networking library for Swift 6 with built-in concurrency, request interceptors, and exponential backoff retries.

[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange?style=flat-square&logo=swift)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue?style=flat-square&logo=apple)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen?style=flat-square)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)](LICENSE)

---

## Highlights

- ⚡ **Pure Swift Concurrency**: Actor-isolated `NetworkClient` with full `Sendable` compliance.
- 🔁 **Automatic Exponential Backoff**: Configurable `RetryPolicy` for resilient handling of transient 5xx server errors and network drops.
- 🔌 **Pluggable Interceptors**: Cleanly inject auth headers, API tokens, loggers, or request signatures.
- 🎯 **Declarative Endpoints**: Clean protocol-oriented design replacing massive URL building boilerplate.

---

## Installation

Add **ModernNetworking** via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/nilkanthdesai76/swift-modern-networking.git", from: "1.0.0")
]
```

---

## Quick Example

### 1. Define an Endpoint

```swift
import Foundation
import ModernNetworking

struct UserProfileEndpoint: Endpoint {
    let userId: String

    var baseURL: URL { URL(string: "https://api.example.com/v1")! }
    var path: String { "users/\(userId)" }
    var method: HTTPMethod { .get }
}
```

### 2. Execute Requests

```swift
import ModernNetworking

struct User: Codable, Sendable {
    let id: String
    let name: String
}

let client = NetworkClient()
let user: User = try await client.send(UserProfileEndpoint(userId: "42"))
print("Loaded user: \(user.name)")
```

### 3. Add an Auth Interceptor

```swift
struct BearerAuthInterceptor: RequestInterceptor {
    let token: String

    func intercept(_ request: inout URLRequest) async throws {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

let client = NetworkClient(interceptors: [BearerAuthInterceptor(token: "token_here")])
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
