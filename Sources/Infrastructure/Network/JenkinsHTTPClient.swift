/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:42
 * Last Updated: 2026-01-01T18:27:25
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain

/// HTTP client for Jenkins API communication
final class JenkinsHTTPClient: Sendable {
    private let session: URLSession
    private let credentials: JenkinsCredentials

    init(credentials: JenkinsCredentials) {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpCookieStorage = HTTPCookieStorage.shared

        self.session = URLSession(configuration: configuration)
        self.credentials = credentials
    }

    /// Performs a GET request to the Jenkins API
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        // Build URL properly to avoid double-encoding query parameters
        let baseURLString = credentials.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fullURLString = baseURLString + "/" + endpoint

        guard let url = URL(string: fullURLString) else {
            throw JenkinsHTTPError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add authentication if provided
        if let username = credentials.username, let apiToken = credentials.apiToken {
            let authString = "\(username):\(apiToken)"
            if let authData = authString.data(using: .utf8) {
                let base64Auth = authData.base64EncodedString()
                request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")

                #if DEBUG
                print("[JenkinsHTTPClient] Authenticating as user: \(username)")
                print("[JenkinsHTTPClient] Request URL: \(url)")
                #endif
            }
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: Invalid HTTP response")
            #endif
            throw JenkinsHTTPError.invalidResponse
        }

        #if DEBUG
        print("[JenkinsHTTPClient] Response status: \(httpResponse.statusCode)")
        print("[JenkinsHTTPClient] Response data size: \(data.count) bytes")
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            // Success
            break
        case 401:
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: 401 Unauthorized")
            if let responseBody = String(data: data, encoding: .utf8) {
                print("[JenkinsHTTPClient] Response body: \(responseBody)")
            }
            #endif
            throw JenkinsHTTPError.authenticationFailed
        case 403:
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: 403 Forbidden")
            if let responseBody = String(data: data, encoding: .utf8) {
                print("[JenkinsHTTPClient] Response body: \(responseBody)")
            }
            #endif
            throw JenkinsHTTPError.forbidden
        case 404:
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: 404 Not Found")
            #endif
            throw JenkinsHTTPError.notFound
        case 500...599:
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: Server error \(httpResponse.statusCode)")
            #endif
            throw JenkinsHTTPError.serverError(httpResponse.statusCode, String(data: data, encoding: .utf8))
        default:
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: Unexpected status code \(httpResponse.statusCode)")
            #endif
            throw JenkinsHTTPError.unexpectedStatusCode(httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            #if DEBUG
            print("[JenkinsHTTPClient] Successfully decoded response")
            #endif
            return decoded
        } catch {
            #if DEBUG
            print("[JenkinsHTTPClient] ERROR: Failed to decode JSON: \(error)")
            if let responseBody = String(data: data, encoding: .utf8) {
                print("[JenkinsHTTPClient] Response body: \(responseBody.prefix(500))")
            }
            #endif
            throw JenkinsHTTPError.decodingFailed(error)
        }
    }
}

/// Errors that can occur during HTTP communication with Jenkins
enum JenkinsHTTPError: Error, LocalizedError {
    case invalidResponse
    case authenticationFailed
    case forbidden
    case notFound
    case serverError(Int, String?)
    case unexpectedStatusCode(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid HTTP response received."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .forbidden:
            return "Access forbidden. Please check your permissions."
        case .notFound:
            return "Requested resource not found."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        case .unexpectedStatusCode(let code):
            return "Unexpected HTTP status code: \(code)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
