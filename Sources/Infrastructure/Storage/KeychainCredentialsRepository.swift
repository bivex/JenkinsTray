/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:47
 * Last Updated: 2026-01-01T18:27:23
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Security

/// Repository implementation for storing Jenkins credentials in macOS Keychain
public final class KeychainCredentialsRepository: CredentialsRepository {
    private let serviceName = "com.jenkinstray.credentials"
    private let accountName = "jenkins"

    public init() {}

    public func saveCredentials(_ credentials: JenkinsCredentials) async throws {
        #if DEBUG
        print("[KeychainCredentialsRepository] Saving credentials for: \(credentials.baseURL)")
        if let username = credentials.username {
            print("[KeychainCredentialsRepository] Username: \(username)")
        }
        #endif

        // Convert credentials to data
        let credentialsData = try JSONEncoder().encode(credentials)

        // Delete existing credentials first
        try? await deleteCredentials()

        // Prepare keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: credentialsData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            #if DEBUG
            print("[KeychainCredentialsRepository] Failed to save credentials: \(status)")
            #endif
            throw CredentialsRepositoryError.saveFailed(KeychainError.fromOSStatus(status))
        }

        #if DEBUG
        print("[KeychainCredentialsRepository] Credentials saved successfully to Keychain")
        #endif
    }

    public func loadCredentials() async throws -> JenkinsCredentials? {
        #if DEBUG
        print("[KeychainCredentialsRepository] Loading credentials from Keychain...")
        #endif

        // Prepare keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                #if DEBUG
                print("[KeychainCredentialsRepository] Invalid data format in Keychain")
                #endif
                throw CredentialsRepositoryError.loadFailed(KeychainError.invalidData)
            }

            let credentials = try JSONDecoder().decode(JenkinsCredentials.self, from: data)
            #if DEBUG
            print("[KeychainCredentialsRepository] Credentials loaded successfully")
            print("[KeychainCredentialsRepository] Base URL: \(credentials.baseURL)")
            if let username = credentials.username {
                print("[KeychainCredentialsRepository] Username: \(username)")
            }
            #endif
            return credentials

        case errSecItemNotFound:
            #if DEBUG
            print("[KeychainCredentialsRepository] No saved credentials found")
            #endif
            return nil

        default:
            #if DEBUG
            print("[KeychainCredentialsRepository] Failed to load credentials: \(status)")
            #endif
            throw CredentialsRepositoryError.loadFailed(KeychainError.fromOSStatus(status))
        }
    }

    public func deleteCredentials() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName
        ]

        let status = SecItemDelete(query as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound:
            // Success or already deleted
            break
        default:
            throw CredentialsRepositoryError.deleteFailed(KeychainError.fromOSStatus(status))
        }
    }
}

/// Keychain-specific errors
private enum KeychainError: Error, LocalizedError {
    case osStatus(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .osStatus(let status):
            return "Keychain error: \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")"
        case .invalidData:
            return "Invalid data retrieved from Keychain."
        }
    }

    static func fromOSStatus(_ status: OSStatus) -> KeychainError {
        .osStatus(status)
    }
}
