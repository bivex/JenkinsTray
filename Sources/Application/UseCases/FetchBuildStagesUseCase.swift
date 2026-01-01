/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:32
 * Last Updated: 2026-01-01T18:27:34
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Domain

/// Use case for fetching build stages for a specific build
public final class FetchBuildStagesUseCase: Sendable {
    private let buildsRepository: BuildsRepository

    public init(buildsRepository: BuildsRepository) {
        self.buildsRepository = buildsRepository
    }

    /// Executes the use case to fetch stages for a specific build
    public func execute(for buildId: Int) async throws -> [BuildStage] {
        try await buildsRepository.fetchBuildStages(for: buildId)
    }
}
