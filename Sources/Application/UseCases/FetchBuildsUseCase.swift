/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:33
 * Last Updated: 2026-01-01T18:27:32
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Domain

/// Use case for fetching Jenkins builds
public final class FetchBuildsUseCase: Sendable {
    private let buildsRepository: BuildsRepository

    public init(buildsRepository: BuildsRepository) {
        self.buildsRepository = buildsRepository
    }

    /// Executes the use case to fetch all completed builds
    public func execute() async throws -> [Build] {
        try await buildsRepository.fetchBuilds()
    }
}
