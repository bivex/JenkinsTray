/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T18:40:00
 * Last Updated: 2026-01-01T18:40:00
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Repository protocol for app settings persistence
public protocol SettingsRepository: Sendable {
    func saveSettings(_ settings: AppSettings) async throws
    func loadSettings() async throws -> AppSettings
}

/// Errors that can occur in settings repository
public enum SettingsRepositoryError: Error, LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save settings: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load settings: \(error.localizedDescription)"
        }
    }
}
