/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:38
 * Last Updated: 2026-01-01T18:27:26
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Protocol for managing Jenkins credentials storage
public protocol CredentialsRepository: Sendable {
    /// Saves Jenkins credentials
    func saveCredentials(_ credentials: JenkinsCredentials) async throws

    /// Loads stored Jenkins credentials
    func loadCredentials() async throws -> JenkinsCredentials?

    /// Deletes stored credentials
    func deleteCredentials() async throws
}

/// Errors that can occur when managing credentials
public enum CredentialsRepositoryError: Error, LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    case invalidCredentials

    public var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save credentials: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load credentials: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete credentials: \(error.localizedDescription)"
        case .invalidCredentials:
            return "Invalid credentials format."
        }
    }
}
