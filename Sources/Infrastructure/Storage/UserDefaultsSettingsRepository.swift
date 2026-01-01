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
import Domain

/// Repository implementation for storing app settings in UserDefaults
public final class UserDefaultsSettingsRepository: SettingsRepository {
    private let settingsKey = "com.jenkinstray.settings"

    public init() {}

    private var userDefaults: UserDefaults {
        .standard
    }

    public func saveSettings(_ settings: AppSettings) async throws {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)

            #if DEBUG
            print("[UserDefaultsSettingsRepository] Settings saved: \(settings.refreshInterval.displayName)")
            #endif
        } catch {
            throw SettingsRepositoryError.saveFailed(error)
        }
    }

    public func loadSettings() async throws -> AppSettings {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            #if DEBUG
            print("[UserDefaultsSettingsRepository] No saved settings, using defaults")
            #endif
            return AppSettings()
        }

        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: data)
            #if DEBUG
            print("[UserDefaultsSettingsRepository] Settings loaded: \(settings.refreshInterval.displayName)")
            #endif
            return settings
        } catch {
            #if DEBUG
            print("[UserDefaultsSettingsRepository] Failed to decode settings, using defaults")
            #endif
            return AppSettings()
        }
    }
}
