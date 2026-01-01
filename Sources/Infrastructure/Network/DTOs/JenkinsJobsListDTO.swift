/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01
 * Last Updated: 2026-01-01
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// DTO for Jenkins job item
struct JenkinsJobItemDTO: Codable {
    let name: String
    let url: String
    let _class: String
    let jobs: [JenkinsJobItemDTO]?

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case _class = "_class"  // JSON key is "_class" with underscore
        case jobs
    }

    /// Check if this is a folder (contains sub-jobs)
    var isFolder: Bool {
        _class.contains("Folder") || jobs != nil
    }
}

/// DTO for Jenkins jobs list response
struct JenkinsJobsListDTO: Codable {
    let jobs: [JenkinsJobItemDTO]

    enum CodingKeys: String, CodingKey {
        case jobs
    }
}
