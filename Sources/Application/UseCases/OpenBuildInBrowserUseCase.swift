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

/// Use case for opening a build in the default web browser
public protocol OpenBuildInBrowserUseCase: Sendable {
    /// Opens the specified build in the default web browser
    func execute(build: Build) async throws
}

/// Default implementation of OpenBuildInBrowserUseCase
public final class DefaultOpenBuildInBrowserUseCase: OpenBuildInBrowserUseCase {
    public init() {}

    public func execute(build: Build) async throws {
        #if canImport(AppKit)
        try await NSWorkspace.shared.open(build.url)
        #elseif canImport(UIKit)
        await UIApplication.shared.open(build.url)
        #else
        throw OpenBuildInBrowserError.unsupportedPlatform
        #endif
    }
}

/// Errors that can occur when opening builds in browser
public enum OpenBuildInBrowserError: Error, LocalizedError {
    case unsupportedPlatform
    case cannotOpenURL(URL)

    public var errorDescription: String? {
        switch self {
        case .unsupportedPlatform:
            return "Opening URLs is not supported on this platform."
        case .cannotOpenURL(let url):
            return "Cannot open URL: \(url.absoluteString)"
        }
    }
}

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif
