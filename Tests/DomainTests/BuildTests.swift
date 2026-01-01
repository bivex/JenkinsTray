/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:41:07
 * Last Updated: 2026-01-01T18:27:18
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import XCTest
@testable import Domain

final class BuildTests: XCTestCase {
    func testBuildInitialization() {
        let timestamp = Date()
        let url = URL(string: "https://example.com/build/123")!

        let build = Build(
            id: 123,
            result: .success,
            timestamp: timestamp,
            duration: 300.0,
            url: url
        )

        XCTAssertEqual(build.id, 123)
        XCTAssertEqual(build.result, .success)
        XCTAssertEqual(build.timestamp, timestamp)
        XCTAssertEqual(build.duration, 300.0)
        XCTAssertEqual(build.url, url)
    }

    func testBuildResultColorMapping() {
        XCTAssertEqual(BuildResult.success.color, .green)
        XCTAssertEqual(BuildResult.failure.color, .red)
        XCTAssertEqual(BuildResult.unstable.color, .yellow)
        XCTAssertEqual(BuildResult.aborted.color, .gray)
    }
}
