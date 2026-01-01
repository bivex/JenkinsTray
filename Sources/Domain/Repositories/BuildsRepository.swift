/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:38
 * Last Updated: 2026-01-01T18:27:27
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Protocol for accessing Jenkins builds data
public protocol BuildsRepository: Sendable {
    /// Fetches all completed builds for the configured Jenkins job
    func fetchBuilds() async throws -> [Build]

    /// Fetches build stages for a specific build
    func fetchBuildStages(for buildId: Int) async throws -> [BuildStage]
}

/// Errors that can occur when accessing builds data
public enum BuildsRepositoryError: Error, LocalizedError {
    case networkError(Error)
    case authenticationError
    case invalidResponse
    case buildNotFound(Int)
    case serverError(Int, String?)

    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationError:
            return "Authentication failed. Please check your credentials."
        case .invalidResponse:
            return "Invalid response from Jenkins server."
        case .buildNotFound(let buildId):
            return "Build #\(buildId) not found."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        }
    }
}
