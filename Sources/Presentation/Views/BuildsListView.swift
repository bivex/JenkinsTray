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
import Domain

struct BuildsListView: View {
    let builds: [Build]
    @Binding var selectedBuildId: Build.ID?
    @Binding var sortOrder: BuildSortOrder
    @Binding var filterResult: BuildResult?
    let isLoading: Bool
    let onRefresh: () -> Void
    let onSelectBuild: (Build) -> Void

    private var selectedBuild: Build? {
        builds.first { $0.id == selectedBuildId }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: onRefresh) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)

                Spacer()

                // Sort picker
                Picker("Sort", selection: $sortOrder) {
                    ForEach([
                        BuildSortOrder.byNumberDescending,
                        BuildSortOrder.byNumberAscending,
                        BuildSortOrder.byDateDescending,
                        BuildSortOrder.byDateAscending
                    ], id: \.self) { order in
                        Text(order.displayName).tag(order)
                    }
                }
                .frame(width: 180)

                // Filter picker
                Picker("Filter", selection: $filterResult) {
                    Text("All").tag(BuildResult?.none)
                    ForEach([BuildResult.success, .failure, .unstable], id: \.self) { result in
                        Text(result.displayName).tag(result as BuildResult?)
                    }
                }
                .frame(width: 120)
            }
            .padding()

            // Builds table
            Table(builds, selection: $selectedBuildId) {
                TableColumn("Build #") { build in
                    Text("#\(build.id)")
                        .foregroundColor(build.result.color.swiftUIColor)
                }
                .width(min: 80, max: 100)

                TableColumn("Result") { build in
                    HStack {
                        Circle()
                            .fill(build.result.color.swiftUIColor)
                            .frame(width: 12, height: 12)
                        Text(build.result.displayName)
                    }
                }
                .width(min: 100, max: 120)

                TableColumn("Date") { build in
                    Text(build.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .width(min: 140, max: 160)

                TableColumn("Duration") { build in
                    Text(formatDuration(build.duration))
                }
                .width(min: 100, max: 120)
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
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
extension BuildResult {
    var displayName: String {
        switch self {
        case .success: return "Success"
        case .failure: return "Failure"
        case .unstable: return "Unstable"
        case .aborted: return "Aborted"
        case .notBuilt: return "Not Built"
        case .unknown: return "Unknown"
        }
    }
}

extension BuildResultColor {
    var swiftUIColor: Color {
        switch self {
        case .green: return .green
        case .red: return .red
        case .yellow: return .yellow
        case .gray: return .gray
        }
    }
}
