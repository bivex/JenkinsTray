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

import SwiftUI
import Domain

struct SettingsView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @State private var selectedInterval: RefreshInterval
    @State private var notificationsEnabled: Bool
    @State private var autoShowPopover: Bool
    @State private var jenkinsURL: String
    @State private var username: String
    @State private var apiToken: String
    @State private var jobPath: String
    @Environment(\.dismiss) private var dismiss

    init() {
        _selectedInterval = State(initialValue: .oneMinute)
        _notificationsEnabled = State(initialValue: true)
        _autoShowPopover = State(initialValue: true)
        _jenkinsURL = State(initialValue: "")
        _username = State(initialValue: "")
        _apiToken = State(initialValue: "")
        _jobPath = State(initialValue: "job/test-app/job/main")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                // Jenkins Connection Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Jenkins URL")
                            .font(.caption)
                        TextField("https://your-jenkins.com", text: $jenkinsURL)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.caption)
                        TextField("Enter username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Token")
                            .font(.caption)
                        SecureField("Enter API token", text: $apiToken)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Job Path")
                            .font(.caption)
                        TextField("job/test-app/job/main", text: $jobPath)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("Jenkins Connection")
                        .font(.headline)
                } footer: {
                    Text("Job path example: job/project-name/job/main")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Refresh Interval Section
                Section {
                    Picker("Refresh Interval", selection: $selectedInterval) {
                        ForEach(RefreshInterval.allCases, id: \.self) { interval in
                            Text(interval.displayName).tag(interval)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Auto Refresh")
                        .font(.headline)
                }

                // Notifications Section
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .help("Receive notifications when build status changes")

                    Toggle("Auto-show Popover", isOn: $autoShowPopover)
                        .help("Automatically show popover when build fails or succeeds")
                } header: {
                    Text("Notifications")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)

            // Action Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveSettings()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 450, height: 500)
        .onAppear {
            // Load current settings
            selectedInterval = appCoordinator.settings.refreshInterval
            notificationsEnabled = appCoordinator.settings.notificationsEnabled
            autoShowPopover = appCoordinator.settings.autoShowPopover
            jobPath = appCoordinator.settings.jobPath

            // Load current credentials
            Task {
                await loadCurrentCredentials()
            }
        }
    }

    private func loadCurrentCredentials() async {
        if let credentials = await appCoordinator.getCurrentCredentials() {
            jenkinsURL = credentials.baseURL.absoluteString
            username = credentials.username ?? ""
            apiToken = credentials.apiToken ?? ""
        }
    }

    private func saveSettings() {
        let trimmedJobPath = jobPath.trimmingCharacters(in: .whitespaces)

        let newSettings = AppSettings(
            refreshInterval: selectedInterval,
            notificationsEnabled: notificationsEnabled,
            autoShowPopover: autoShowPopover,
            jobPath: trimmedJobPath.isEmpty ? "job/test-app/job/main" : trimmedJobPath
        )

        Task {
            // Update app settings
            await appCoordinator.updateSettings(newSettings)

            // Update credentials if changed
            let trimmedURL = jenkinsURL.trimmingCharacters(in: .whitespaces)
            let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
            let trimmedApiToken = apiToken.trimmingCharacters(in: .whitespaces)

            if !trimmedURL.isEmpty, !trimmedUsername.isEmpty, !trimmedApiToken.isEmpty {
                if let url = URL(string: trimmedURL) {
                    let credentials = JenkinsCredentials.basicAuth(
                        baseURL: url,
                        username: trimmedUsername,
                        apiToken: trimmedApiToken
                    )
                    try? await appCoordinator.updateCredentials(credentials)
                }
            }

            dismiss()
        }
    }
}
