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

/// Application settings
public struct AppSettings: Codable, Sendable {
    public let refreshInterval: RefreshInterval
    public let notificationsEnabled: Bool
    public let autoShowPopover: Bool

    public init(
        refreshInterval: RefreshInterval = .oneMinute,
        notificationsEnabled: Bool = true,
        autoShowPopover: Bool = true
    ) {
        self.refreshInterval = refreshInterval
        self.notificationsEnabled = notificationsEnabled
        self.autoShowPopover = autoShowPopover
    }
}

/// Refresh interval options
public enum RefreshInterval: Int, Codable, CaseIterable, Sendable {
    case fiveSeconds = 5
    case tenSeconds = 10
    case thirtySeconds = 30
    case oneMinute = 60
    case fiveMinutes = 300

    public var displayName: String {
        switch self {
        case .fiveSeconds: return "5 seconds"
        case .tenSeconds: return "10 seconds"
        case .thirtySeconds: return "30 seconds"
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        }
    }

    public var seconds: TimeInterval {
        TimeInterval(rawValue)
    }
}
