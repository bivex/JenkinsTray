/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:41
 * Last Updated: 2026-01-01T18:27:25
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// DTO for Jenkins build information from API
struct JenkinsBuildDTO: Codable {
    let number: Int
    let result: String?
    let timestamp: Int64?
    let duration: Int64?
    let url: String

    enum CodingKeys: String, CodingKey {
        case number
        case result
        case timestamp
        case duration
        case url
    }
}

/// DTO for Jenkins job response containing builds
struct JenkinsJobDTO: Codable {
    let builds: [JenkinsBuildDTO]

    enum CodingKeys: String, CodingKey {
        case builds
    }
}
