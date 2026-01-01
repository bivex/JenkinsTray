/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T18:27:13
 * Last Updated: 2026-01-01T18:27:23
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import SwiftUI
import Application
import Infrastructure
import Domain
import UserNotifications

@main
struct JenkinsTrayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        let credentialsRepository = KeychainCredentialsRepository()
        let settingsRepository = UserDefaultsSettingsRepository()

        // Start with anonymous credentials, will be updated during authentication
        let buildsRepository = JenkinsBuildsRepository(
            credentials: JenkinsCredentials.anonymous(baseURL: URL(string: "https://build.w-w.top")!)
        )

        let fetchBuildsUseCase = FetchBuildsUseCase(buildsRepository: buildsRepository)
        let fetchBuildStagesUseCase = FetchBuildStagesUseCase(buildsRepository: buildsRepository)
        let refreshDataUseCase = RefreshDataUseCase(fetchBuildsUseCase: fetchBuildsUseCase)
        let openBuildInBrowserUseCase = DefaultOpenBuildInBrowserUseCase()

        let appCoordinator = AppCoordinator(
            fetchBuildsUseCase: fetchBuildsUseCase,
            fetchBuildStagesUseCase: fetchBuildStagesUseCase,
            refreshDataUseCase: refreshDataUseCase,
            openBuildInBrowserUseCase: openBuildInBrowserUseCase,
            credentialsRepository: credentialsRepository,
            settingsRepository: settingsRepository
        )

        _appCoordinator = StateObject(wrappedValue: appCoordinator)

        // Set app coordinator in tray manager
        JenkinsTrayManager.shared.setAppCoordinator(appCoordinator)

        // Request notification permissions (only if running as proper app bundle)
        if Bundle.main.bundleIdentifier != nil {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                #if DEBUG
                if granted {
                    print("[JenkinsTrayApp] Notification permission granted")
                } else {
                    print("[JenkinsTrayApp] Notification permission denied: \(String(describing: error))")
                }
                #endif
            }
        } else {
            #if DEBUG
            print("[JenkinsTrayApp] Skipping notification permission request (not running as app bundle)")
            #endif
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            // Hide standard window commands for tray app
            CommandGroup(replacing: .appInfo) { }
            CommandGroup(replacing: .newItem) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the main window initially for tray app
        NSApp.setActivationPolicy(.accessory)

        // Initialize tray manager
        let _ = JenkinsTrayManager.shared
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up tray icon will be handled by JenkinsTrayManager deinit
    }
}