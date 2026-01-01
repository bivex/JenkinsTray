/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:49
 * Last Updated: 2026-01-01T18:27:12
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import SwiftUI
import Combine
import Application
import Infrastructure
import Domain
import UserNotifications

/// Coordinator responsible for managing app state and coordinating use cases
@MainActor
public final class AppCoordinator: ObservableObject {
    // MARK: - Published State
    @Published var builds: [Build] = []
    @Published var selectedBuild: Build?
    @Published var buildStages: [BuildStage] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isAuthenticated = false
    @Published var settings: AppSettings

    // MARK: - Private Properties
    private var fetchBuildsUseCase: FetchBuildsUseCase
    private var fetchBuildStagesUseCase: FetchBuildStagesUseCase
    private var refreshDataUseCase: RefreshDataUseCase
    private let openBuildInBrowserUseCase: OpenBuildInBrowserUseCase
    private let credentialsRepository: CredentialsRepository
    private let settingsRepository: SettingsRepository

    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private var lastBuildStatus: BuildResult?

    // MARK: - Initialization
    public init(
        fetchBuildsUseCase: FetchBuildsUseCase,
        fetchBuildStagesUseCase: FetchBuildStagesUseCase,
        refreshDataUseCase: RefreshDataUseCase,
        openBuildInBrowserUseCase: OpenBuildInBrowserUseCase,
        credentialsRepository: CredentialsRepository,
        settingsRepository: SettingsRepository
    ) {
        self.fetchBuildsUseCase = fetchBuildsUseCase
        self.fetchBuildStagesUseCase = fetchBuildStagesUseCase
        self.refreshDataUseCase = refreshDataUseCase
        self.openBuildInBrowserUseCase = openBuildInBrowserUseCase
        self.credentialsRepository = credentialsRepository
        self.settingsRepository = settingsRepository
        self.settings = AppSettings() // Default settings

        // Check for saved credentials and settings
        Task {
            await loadSettings()
            await checkAuthenticationStatus()
        }
    }

    // MARK: - Public Methods
    func refreshData() async {
        await loadBuilds()
    }

    func selectBuild(_ build: Build?) async {
        selectedBuild = build

        if let build = build {
            await loadBuildStages(for: build.id)
        } else {
            buildStages = []
        }
    }

    func openBuildInBrowser(_ build: Build) async {
        do {
            try await openBuildInBrowserUseCase.execute(build: build)
        } catch {
            self.error = error
        }
    }

    func authenticate(with credentials: JenkinsCredentials) async throws {
        #if DEBUG
        print("[AppCoordinator] Attempting authentication...")
        #endif

        // Save credentials
        try await credentialsRepository.saveCredentials(credentials)

        #if DEBUG
        print("[AppCoordinator] Credentials saved to Keychain")
        #endif

        // Update repository with new credentials
        updateRepository(with: credentials)

        // Test authentication by trying to fetch builds
        do {
            _ = try await refreshDataUseCase.execute()
            isAuthenticated = true
            error = nil

            // Start periodic refresh timer
            setupRefreshTimer()

            #if DEBUG
            print("[AppCoordinator] Authentication successful!")
            #endif
        } catch {
            #if DEBUG
            print("[AppCoordinator] Authentication failed, removing invalid credentials")
            #endif
            // Remove invalid credentials
            try? await credentialsRepository.deleteCredentials()
            throw error
        }
    }

    private func updateRepository(with credentials: JenkinsCredentials) {
        let buildsRepository = JenkinsBuildsRepository(credentials: credentials)
        self.fetchBuildsUseCase = FetchBuildsUseCase(buildsRepository: buildsRepository)
        self.fetchBuildStagesUseCase = FetchBuildStagesUseCase(buildsRepository: buildsRepository)
        self.refreshDataUseCase = RefreshDataUseCase(fetchBuildsUseCase: fetchBuildsUseCase)
    }

    func logout() async {
        do {
            try await credentialsRepository.deleteCredentials()
            isAuthenticated = false
            builds = []
            buildStages = []
            selectedBuild = nil
            error = nil
        } catch {
            self.error = error
        }
    }

    // MARK: - Private Methods
    private func checkAuthenticationStatus() async {
        #if DEBUG
        print("[AppCoordinator] Checking authentication status...")
        #endif

        do {
            if let credentials = try await credentialsRepository.loadCredentials() {
                #if DEBUG
                print("[AppCoordinator] Saved credentials found, restoring session...")
                #endif
                // Update repository with loaded credentials
                updateRepository(with: credentials)
                isAuthenticated = true
                await loadBuilds()

                // Start periodic refresh timer
                setupRefreshTimer()
            } else {
                #if DEBUG
                print("[AppCoordinator] No saved credentials, user needs to login")
                #endif
                isAuthenticated = false
            }
        } catch {
            #if DEBUG
            print("[AppCoordinator] Error loading credentials: \(error.localizedDescription)")
            #endif
            isAuthenticated = false
            self.error = error
        }
    }

    private func loadBuilds() async {
        guard isAuthenticated else { return }

        isLoading = true
        error = nil

        do {
            builds = try await refreshDataUseCase.execute()
        } catch {
            self.error = error
            // If authentication fails, mark as unauthenticated
            if let buildsError = error as? BuildsRepositoryError,
               case .authenticationError = buildsError {
                isAuthenticated = false
                try? await credentialsRepository.deleteCredentials()
            }
        }

        isLoading = false
    }

    private func loadBuildStages(for buildId: Int) async {
        do {
            buildStages = try await fetchBuildStagesUseCase.execute(for: buildId)
        } catch {
            self.error = error
            buildStages = []
        }
    }

    // MARK: - Settings Management
    func loadSettings() async {
        do {
            settings = try await settingsRepository.loadSettings()
            #if DEBUG
            print("[AppCoordinator] Settings loaded, refresh interval: \(settings.refreshInterval.displayName)")
            #endif
            setupRefreshTimer()
        } catch {
            #if DEBUG
            print("[AppCoordinator] Failed to load settings: \(error.localizedDescription)")
            #endif
        }
    }

    func updateSettings(_ newSettings: AppSettings) async {
        do {
            try await settingsRepository.saveSettings(newSettings)
            settings = newSettings
            #if DEBUG
            print("[AppCoordinator] Settings updated, refresh interval: \(settings.refreshInterval.displayName)")
            #endif
            setupRefreshTimer()
        } catch {
            self.error = error
        }
    }

    // MARK: - Credentials Management
    func getCurrentCredentials() async -> JenkinsCredentials? {
        do {
            return try await credentialsRepository.loadCredentials()
        } catch {
            #if DEBUG
            print("[AppCoordinator] Failed to load credentials: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func updateCredentials(_ credentials: JenkinsCredentials) async throws {
        #if DEBUG
        print("[AppCoordinator] Updating credentials...")
        #endif

        // Save new credentials
        try await credentialsRepository.saveCredentials(credentials)

        #if DEBUG
        print("[AppCoordinator] Credentials saved, updating repository...")
        #endif

        // Update repository with new credentials
        updateRepository(with: credentials)

        // Test authentication by trying to fetch builds
        do {
            _ = try await refreshDataUseCase.execute()
            error = nil

            // Restart refresh timer with new credentials
            setupRefreshTimer()

            #if DEBUG
            print("[AppCoordinator] Credentials updated successfully!")
            #endif
        } catch {
            #if DEBUG
            print("[AppCoordinator] Credential update failed, reverting...")
            #endif
            // Remove invalid credentials
            try? await credentialsRepository.deleteCredentials()
            throw error
        }
    }

    // MARK: - Periodic Refresh
    private func setupRefreshTimer() {
        // Invalidate existing timer
        refreshTimer?.invalidate()

        guard isAuthenticated else { return }

        #if DEBUG
        print("[AppCoordinator] Setting up refresh timer: \(settings.refreshInterval.displayName)")
        #endif

        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: settings.refreshInterval.seconds,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.periodicRefresh()
            }
        }
    }

    private func periodicRefresh() async {
        guard isAuthenticated else { return }

        #if DEBUG
        print("[AppCoordinator] Periodic refresh triggered")
        #endif

        // Track previous build ID and status
        let previousBuildId = builds.first?.id
        let previousStatus = builds.first?.result

        await loadBuilds()

        // Get new build info
        let newBuildId = builds.first?.id
        let newStatus = builds.first?.result

        #if DEBUG
        print("[AppCoordinator] Previous build: #\(previousBuildId ?? 0) - \(previousStatus?.rawValue ?? "none")")
        print("[AppCoordinator] Current build: #\(newBuildId ?? 0) - \(newStatus?.rawValue ?? "none")")
        #endif

        // Send notification if:
        // 1. Notifications are enabled
        // 2. Build status changed (different status OR different build ID)
        guard settings.notificationsEnabled else { return }

        if let newStatus = newStatus {
            var shouldShowPopover = false

            // New build appeared
            if let prevId = previousBuildId, let newId = newBuildId, newId != prevId {
                #if DEBUG
                print("[AppCoordinator] New build detected, sending notification")
                #endif
                sendNotification(for: newStatus)
                shouldShowPopover = true
            }
            // Build status changed
            else if let previous = previousStatus, newStatus != previous {
                #if DEBUG
                print("[AppCoordinator] Build status changed, sending notification")
                #endif
                sendNotification(for: newStatus)
                shouldShowPopover = true
            }

            // Show popover and main window for failures and successes (if enabled in settings)
            if shouldShowPopover && settings.autoShowPopover && (newStatus == .failure || newStatus == .success) {
                #if DEBUG
                print("[AppCoordinator] Showing popover and main window for \(newStatus.rawValue)")
                #endif
                JenkinsTrayManager.shared.showPopoverWithAlert()
                JenkinsTrayManager.shared.showMainWindow()
            }
        }
    }

    private func sendNotification(for buildResult: BuildResult) {
        #if DEBUG
        print("[AppCoordinator] sendNotification called for: \(buildResult.rawValue)")
        #endif

        // Only send notifications if running as proper app bundle
        guard Bundle.main.bundleIdentifier != nil else {
            #if DEBUG
            print("[AppCoordinator] ❌ Skipping notification (not running as app bundle)")
            #endif
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Jenkins Build Status"

        switch buildResult {
        case .success:
            content.body = "✅ Build succeeded!"
            content.sound = .default
        case .failure:
            content.body = "❌ Build failed!"
            content.sound = .defaultCritical
        case .unstable:
            content.body = "⚠️ Build unstable"
            content.sound = .default
        case .aborted:
            content.body = "🛑 Build aborted"
            content.sound = .default
        case .notBuilt, .unknown:
            content.body = "ℹ️ Build status changed"
            content.sound = .default
        }

        #if DEBUG
        print("[AppCoordinator] 🔔 Sending notification: \(content.body)")
        #endif

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("[AppCoordinator] ❌ Failed to send notification: \(error)")
                #endif
            } else {
                #if DEBUG
                print("[AppCoordinator] ✅ Notification sent successfully")
                #endif
            }
        }
    }

}
