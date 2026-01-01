/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T18:27:17
 * Last Updated: 2026-01-01T18:27:17
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import XCTest
@testable import Application
@testable import Domain

final class FetchBuildsUseCaseTests: XCTestCase {
    private var mockRepository: MockBuildsRepository!
    private var useCase: FetchBuildsUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockBuildsRepository()
        useCase = FetchBuildsUseCase(buildsRepository: mockRepository)
    }

    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    func testExecuteReturnsBuildsFromRepository() async throws {
        let expectedBuilds = [
            Build(id: 1, result: .success, timestamp: Date(), duration: 100, url: URL(string: "https://example.com")!),
            Build(id: 2, result: .failure, timestamp: Date(), duration: 200, url: URL(string: "https://example.com")!)
        ]
        mockRepository.buildsToReturn = expectedBuilds

        let result = try await useCase.execute()

        XCTAssertEqual(result, expectedBuilds)
        XCTAssertTrue(mockRepository.fetchBuildsCalled)
    }

    func testExecuteThrowsErrorWhenRepositoryFails() async {
        mockRepository.errorToThrow = BuildsRepositoryError.networkError(NSError(domain: "test", code: 1))

        do {
            _ = try await useCase.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is BuildsRepositoryError)
        }
    }
}

// MARK: - Mock
private class MockBuildsRepository: BuildsRepository {
    var buildsToReturn: [Build] = []
    var errorToThrow: Error?
    var fetchBuildsCalled = false

    func fetchBuilds() async throws -> [Build] {
        fetchBuildsCalled = true

        if let error = errorToThrow {
            throw error
        }

        return buildsToReturn
    }

    func fetchBuildStages(for buildId: Int) async throws -> [BuildStage] {
        return []
    }
}
