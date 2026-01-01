/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:39:39
 * Last Updated: 2026-01-01T18:27:18
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

// swift-tools-version: 6.0
// The swift-tools version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JenkinsTray",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "JenkinsTray",
            targets: ["Presentation"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Domain Layer - Pure business logic, no external dependencies
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain"
        ),

        // Application Layer - Use cases and application logic
        .target(
            name: "Application",
            dependencies: ["Domain"],
            path: "Sources/Application"
        ),

        // Infrastructure Layer - External dependencies, adapters
        .target(
            name: "Infrastructure",
            dependencies: ["Domain", "Application"],
            path: "Sources/Infrastructure",
            linkerSettings: [
                .linkedFramework("Security", .when(platforms: [.macOS]))
            ]
        ),

        // Presentation Layer - UI and user interaction (contains @main)
        .executableTarget(
            name: "Presentation",
            dependencies: ["Application", "Infrastructure"],
            path: "Sources/Presentation"
        ),

        // Tests
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "Tests/DomainTests"
        ),
        .testTarget(
            name: "ApplicationTests",
            dependencies: ["Application"],
            path: "Tests/ApplicationTests"
        ),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: ["Infrastructure"],
            path: "Tests/InfrastructureTests"
        )
    ]
)
