/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:34
 * Last Updated: 2026-01-01T18:27:32
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Domain

/// Use case for refreshing Jenkins data
public final class RefreshDataUseCase: Sendable {
    private let fetchBuildsUseCase: FetchBuildsUseCase

    public init(fetchBuildsUseCase: FetchBuildsUseCase) {
        self.fetchBuildsUseCase = fetchBuildsUseCase
    }

    /// Executes the use case to refresh all build data
    public func execute() async throws -> [Build] {
        try await fetchBuildsUseCase.execute()
    }
}
