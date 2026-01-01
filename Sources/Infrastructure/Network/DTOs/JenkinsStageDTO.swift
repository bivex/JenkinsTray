/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:41
 * Last Updated: 2026-01-01T18:27:05
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// DTO for Jenkins workflow stage information
struct JenkinsStageDTO: Codable {
    let id: String
    let name: String
    let status: String
    let durationMillis: Int64?
    let startTimeMillis: Int64?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case durationMillis
        case startTimeMillis
    }
}

/// DTO for Jenkins workflow description response
struct JenkinsWorkflowDTO: Codable {
    let stages: [JenkinsStageDTO]

    enum CodingKeys: String, CodingKey {
        case stages
    }
}
