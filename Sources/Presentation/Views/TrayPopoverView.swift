/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T18:27:16
 * Last Updated: 2026-01-01T18:27:16
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import SwiftUI
import Combine
import Application
import Domain

struct TrayPopoverView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @State private var isAuthenticated = false
    @State private var showSettings = false

    @State private var baseURL = "https://build.w-w.top"
    @State private var username = ""
    @State private var apiToken = ""
    @State private var authMethod: AuthMethod = .basicAuth
    @State private var isAuthenticating = false
    @State private var errorMessage = ""

    enum AuthMethod: String, CaseIterable {
        case basicAuth = "Authenticated"
        case anonymous = "Anonymous"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "hammer.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("JenkinsTray")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                // Sync authentication state
                isAuthenticated = appCoordinator.isAuthenticated
            }

            // Authentication status
            if isAuthenticated {
                authenticatedView
            } else {
                authenticationForm
            }

            Spacer()

            // Footer with version info
            HStack {
                Spacer()
                Text("v1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(width: 280, height: 350)
        .padding(.vertical)
        .onChange(of: JenkinsTrayManager.shared.showPopover) { isShown in
            if !isShown {
                // Clear sensitive data when popover closes
                username = ""
                apiToken = ""
                errorMessage = ""
            }
        }
    }

    private var authenticatedView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Authenticated")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            Divider()

            Button(action: openMainWindow) {
                Label("Open Jenkins View", systemImage: "window")
            }
            .buttonStyle(.bordered)

            Button(action: { showSettings = true }) {
                Label("Settings", systemImage: "gear")
            }
            .buttonStyle(.bordered)

            Button(action: logout) {
                Label("Logout", systemImage: "arrow.right.square")
            }
            .buttonStyle(.bordered)
            .foregroundColor(.orange)

            Button(action: exitApp) {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appCoordinator)
        }
    }

    private var authenticationForm: some View {
        VStack(spacing: 12) {
            // URL field
            VStack(alignment: .leading, spacing: 4) {
                Text("Jenkins URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("https://your-jenkins.com", text: $baseURL)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }

            // Auth method picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Authentication Method")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("", selection: $authMethod) {
                    ForEach(AuthMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Credentials fields based on auth method
            switch authMethod {
            case .basicAuth:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Username")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    Text("API Token")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Enter API token", text: $apiToken)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
            case .anonymous:
                Text("No authentication required")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }

            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            // Login button
            Button(action: authenticate) {
                if isAuthenticating {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAuthenticating || !canAuthenticate)
        }
        .padding(.horizontal)
    }

    private var canAuthenticate: Bool {
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespaces)
        guard URL(string: trimmedURL) != nil, !trimmedURL.isEmpty else { return false }

        switch authMethod {
        case .basicAuth:
            let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
            let trimmedApiToken = apiToken.trimmingCharacters(in: .whitespaces)
            return !trimmedUsername.isEmpty && !trimmedApiToken.isEmpty
        case .anonymous:
            return true
        }
    }

    private func authenticate() {
        guard let baseURL = URL(string: baseURL.trimmingCharacters(in: .whitespaces)) else {
            errorMessage = "Invalid URL"
            return
        }

        isAuthenticating = true
        errorMessage = ""

        Task {
            let credentials: JenkinsCredentials
            let usernameForError: String?

            switch authMethod {
            case .basicAuth:
                // Trim whitespace from username and API token to prevent typos
                let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
                let trimmedApiToken = apiToken.trimmingCharacters(in: .whitespaces)

                credentials = .basicAuth(
                    baseURL: baseURL,
                    username: trimmedUsername,
                    apiToken: trimmedApiToken
                )
                usernameForError = trimmedUsername
            case .anonymous:
                credentials = .anonymous(baseURL: baseURL)
                usernameForError = nil
            }

            do {
                try await appCoordinator.authenticate(with: credentials)
                isAuthenticated = true
                JenkinsTrayManager.shared.hidePopover()

            } catch {
                // Provide helpful error message with username for debugging
                if let username = usernameForError, !username.isEmpty {
                    errorMessage = "Authentication failed for user '\(username)': \(error.localizedDescription)"
                } else {
                    errorMessage = error.localizedDescription
                }
            }

            isAuthenticating = false
        }
    }

    private func logout() {
        Task {
            await appCoordinator.logout()
            isAuthenticated = false
        }
    }

    private func openMainWindow() {
        // Show main window
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }

        JenkinsTrayManager.shared.hidePopover()
    }

    private func exitApp() {
        NSApplication.shared.terminate(nil)
    }
}
