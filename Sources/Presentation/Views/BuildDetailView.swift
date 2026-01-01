/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T18:27:15
 * Last Updated: 2026-01-01T18:27:15
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import SwiftUI
import Domain
import AppKit

struct BuildDetailView: View {
    let build: Build
    let stages: [BuildStage]
    let onOpenInBrowser: () -> Void

    @State private var showCopyConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Build header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Build #\(build.id)")
                        .font(.title)
                        .foregroundColor(build.result.color.swiftUIColor)

                    Spacer()

                    HStack(spacing: 8) {
                        Button(action: copyBuildInfo) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .help("Copy build information to clipboard")

                        Button(action: onOpenInBrowser) {
                            Label("Open in Browser", systemImage: "safari")
                        }
                    }
                }

                if showCopyConfirmation {
                    Text("✓ Copied to clipboard")
                        .font(.caption)
                        .foregroundColor(.green)
                        .transition(.opacity)
                }

                HStack(spacing: 16) {
                    Label {
                        Text(build.result.displayName)
                    } icon: {
                        Circle()
                            .fill(build.result.color.swiftUIColor)
                            .frame(width: 12, height: 12)
                    }

                    Label {
                        Text(build.timestamp.formatted(date: .long, time: .shortened))
                    } icon: {
                        Image(systemName: "calendar")
                    }

                    Label {
                        Text(formatDuration(build.duration))
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Divider()

            // Stages section
            VStack(alignment: .leading, spacing: 12) {
                Text("Build Stages")
                    .font(.headline)
                    .padding(.horizontal)

                if stages.isEmpty {
                    Text("No stages information available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(stages) { stage in
                                StageRowView(stage: stage)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: duration) ?? "0s"
    }

    private func copyBuildInfo() {
        var text = ""
        text += "Build #\(build.id)\n"
        text += "Status: \(build.result.displayName)\n"
        text += "Date: \(build.timestamp.formatted(date: .long, time: .shortened))\n"
        text += "Duration: \(formatDuration(build.duration))\n"
        text += "URL: \(build.url.absoluteString)\n"

        if !stages.isEmpty {
            text += "\nStages:\n"
            for stage in stages {
                text += "  • \(stage.name) - \(stage.status.displayName) (\(formatDuration(stage.duration)))\n"
            }
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        withAnimation {
            showCopyConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyConfirmation = false
            }
        }
    }
}

struct StageRowView: View {
    let stage: BuildStage

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(stage.status.color.swiftUIColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name)
                    .font(.body)
                    .lineLimit(1)

                Text(stage.status.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatDuration(stage.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.textBackgroundColor).opacity(0.5))
        .cornerRadius(6)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: duration) ?? "0s"
    }
}

// MARK: - Extensions
extension BuildStageStatus {
    var displayName: String {
        switch self {
        case .success: return "Success"
        case .failure: return "Failure"
        case .unstable: return "Unstable"
        case .aborted: return "Aborted"
        case .notBuilt: return "Not Built"
        case .skipped: return "Skipped"
        case .paused: return "Paused"
        case .unknown: return "Unknown"
        }
    }
}
