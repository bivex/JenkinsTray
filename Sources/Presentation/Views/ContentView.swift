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

public struct ContentView: View {
    public init() {}
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var sortOrder: BuildSortOrder = .byNumberDescending
    @State private var filterResult: BuildResult?

    public var body: some View {
        NavigationSplitView {
            // Sidebar with builds list
            BuildsListView(
                builds: filteredAndSortedBuilds,
                selectedBuildId: .init(
                    get: { coordinator.selectedBuild?.id },
                    set: { id in
                        if let id = id, let build = filteredAndSortedBuilds.first(where: { $0.id == id }) {
                            Task {
                                await coordinator.selectBuild(build)
                            }
                        } else {
                            Task {
                                await coordinator.selectBuild(nil)
                            }
                        }
                    }
                ),
                sortOrder: $sortOrder,
                filterResult: $filterResult,
                isLoading: coordinator.isLoading,
                onRefresh: {
                    Task {
                        await coordinator.refreshData()
                    }
                },
                onSelectBuild: { build in
                    Task {
                        await coordinator.selectBuild(build)
                    }
                }
            )
        } detail: {
            // Detail view with build stages
            if let selectedBuild = coordinator.selectedBuild {
                BuildDetailView(
                    build: selectedBuild,
                    stages: coordinator.buildStages,
                    onOpenInBrowser: {
                        Task {
                            await coordinator.openBuildInBrowser(selectedBuild)
                        }
                    }
                )
            } else {
                Text("Select a build to view details")
                    .foregroundColor(.secondary)
            }
        }
        .alert(
            "Error",
            isPresented: .init(
                get: { coordinator.error != nil },
                set: { if !$0 { coordinator.error = nil } }
            ),
            presenting: coordinator.error
        ) { error in
            Button("OK") {
                coordinator.error = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .frame(minWidth: 800, minHeight: 600)
    }

    private var filteredAndSortedBuilds: [Build] {
        var result = coordinator.builds

        // Apply filter
        if let filterResult = filterResult {
            result = result.filter { $0.result == filterResult }
        }

        // Apply sorting
        result.sort(by: sortOrder.comparator)

        return result
    }
}

// MARK: - Build Sorting
enum BuildSortOrder {
    case byNumberAscending
    case byNumberDescending
    case byDateAscending
    case byDateDescending

    var comparator: (Build, Build) -> Bool {
        switch self {
        case .byNumberAscending:
            return { $0.id < $1.id }
        case .byNumberDescending:
            return { $0.id > $1.id }
        case .byDateAscending:
            return { $0.timestamp < $1.timestamp }
        case .byDateDescending:
            return { $0.timestamp > $1.timestamp }
        }
    }

    var displayName: String {
        switch self {
        case .byNumberAscending:
            return "Build # (Ascending)"
        case .byNumberDescending:
            return "Build # (Descending)"
        case .byDateAscending:
            return "Date (Oldest First)"
        case .byDateDescending:
            return "Date (Newest First)"
        }
    }
}
