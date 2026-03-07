//
//  SyncStatusService.swift
//  kartonche
//
//  Created on 2026-03-07.
//

import Foundation
import CloudKit

enum SyncStatus: Equatable {
    case active
    case signedOut
    case unavailable
    case error
}

struct SyncStatusSnapshot: Equatable {
    let status: SyncStatus
    let lastCheckedAt: Date?
}

protocol CloudAccountStatusProviding {
    func accountStatus() async throws -> CKAccountStatus
}

struct CloudKitAccountStatusProvider: CloudAccountStatusProviding {
    let containerIdentifier: String

    func accountStatus() async throws -> CKAccountStatus {
        try await CKContainer(identifier: containerIdentifier).accountStatus()
    }
}

struct SyncStatusService {
    static let cloudContainerIdentifier = SharedDataManager.cloudContainerIdentifier
    static let lastSyncCheckDateKey = SharedDataManager.lastSyncCheckDateKey

    private let accountStatusProvider: CloudAccountStatusProviding
    private let defaults: UserDefaults
    private let now: () -> Date

    init(
        accountStatusProvider: CloudAccountStatusProviding = CloudKitAccountStatusProvider(
            containerIdentifier: cloudContainerIdentifier
        ),
        defaults: UserDefaults = UserDefaults(suiteName: SharedDataManager.appGroupIdentifier) ?? .standard,
        now: @escaping () -> Date = Date.init
    ) {
        self.accountStatusProvider = accountStatusProvider
        self.defaults = defaults
        self.now = now
    }

    func refreshStatus() async -> SyncStatusSnapshot {
        let previousCheckDate = defaults.object(forKey: Self.lastSyncCheckDateKey) as? Date

        do {
            let accountStatus = try await accountStatusProvider.accountStatus()
            let checkDate = now()
            defaults.set(checkDate, forKey: Self.lastSyncCheckDateKey)

            return SyncStatusSnapshot(
                status: map(accountStatus),
                lastCheckedAt: checkDate
            )
        } catch {
            return SyncStatusSnapshot(
                status: .error,
                lastCheckedAt: previousCheckDate
            )
        }
    }

    private func map(_ accountStatus: CKAccountStatus) -> SyncStatus {
        switch accountStatus {
        case .available:
            return .active
        case .noAccount:
            return .signedOut
        case .couldNotDetermine, .restricted, .temporarilyUnavailable:
            return .unavailable
        @unknown default:
            return .error
        }
    }
}
