/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:36
 * Last Updated: 2026-01-01T18:27:28
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Represents a stage in a Jenkins pipeline build
public struct BuildStage: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let status: BuildStageStatus
    public let duration: TimeInterval
    public let startTimeMillis: Int64?

    public init(
        id: String,
        name: String,
        status: BuildStageStatus,
        duration: TimeInterval,
        startTimeMillis: Int64?
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.duration = duration
        self.startTimeMillis = startTimeMillis
    }
}

/// Represents the status of a build stage
public enum BuildStageStatus: String, Codable, Sendable {
    case success = "SUCCESS"
    case failure = "FAILURE"
    case unstable = "UNSTABLE"
    case aborted = "ABORTED"
    case notBuilt = "NOT_BUILT"
    case skipped = "SKIPPED"
    case paused = "PAUSED"
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
        case .aborted, .notBuilt, .skipped, .paused, .unknown:
            return .gray
        }
    }
}

