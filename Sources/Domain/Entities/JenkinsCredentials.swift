/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T18:27:28
 * Last Updated: 2026-01-01T18:27:30
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Represents credentials for Jenkins authentication
public struct JenkinsCredentials: Codable, Sendable {
    public let baseURL: URL
    public let username: String?
    public let apiToken: String?

    public init(
        baseURL: URL,
        username: String?,
        apiToken: String?
    ) {
        self.baseURL = baseURL
        self.username = username
        self.apiToken = apiToken
    }

    /// Creates credentials for Basic Auth with username and API token
    /// - Parameters:
    ///   - baseURL: The base URL of the Jenkins server
    ///   - username: The Jenkins username
    ///   - apiToken: The Jenkins API token (generated from user settings)
    /// - Note: Both username and API token are required for Jenkins authentication
    public static func basicAuth(baseURL: URL, username: String, apiToken: String) -> JenkinsCredentials {
        JenkinsCredentials(baseURL: baseURL, username: username, apiToken: apiToken)
    }

    /// Creates credentials for anonymous access (no authentication)
    public static func anonymous(baseURL: URL) -> JenkinsCredentials {
        JenkinsCredentials(baseURL: baseURL, username: nil, apiToken: nil)
    }
}