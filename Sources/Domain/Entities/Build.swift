/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:35
 * Last Updated: 2026-01-01T18:27:31
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Represents a Jenkins build with its basic information
public struct Build: Identifiable, Sendable, Equatable {
    public let id: Int
    public let result: BuildResult
    public let timestamp: Date
    public let duration: TimeInterval
    public let url: URL

    public init(
        id: Int,
        result: BuildResult,
        timestamp: Date,
        duration: TimeInterval,
        url: URL
    ) {
        self.id = id
        self.result = result
        self.timestamp = timestamp
        self.duration = duration
        self.url = url
    }
}

/// Represents the result/status of a Jenkins build
public enum BuildResult: String, Codable, Sendable {
    case success = "SUCCESS"
    case failure = "FAILURE"
    case unstable = "UNSTABLE"
    case aborted = "ABORTED"
    case notBuilt = "NOT_BUILT"
    case unknown = "UNKNOWN"

    /// Color representation for UI
    public var color: BuildResultColor {
        switch self {
        case .success:
            return .green
        case .failure:
            return .red
        case .unstable:
            return .yellow
        case .aborted, .notBuilt, .unknown:
            return .gray
        }
    }
}

