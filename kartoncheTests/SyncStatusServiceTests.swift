//
//  SyncStatusServiceTests.swift
//  kartoncheTests
//
//  Created on 2026-03-07.
//

import Foundation
import Testing
import CloudKit
@testable import kartonche

@MainActor
struct SyncStatusServiceTests {

    @Test func activeAccountStatusPersistsLastCheckDate() async {
        let defaults = UserDefaults(suiteName: "SyncStatusServiceTests.active")!
        defaults.removePersistentDomain(forName: "SyncStatusServiceTests.active")

        let expectedDate = Date(timeIntervalSince1970: 1_234_567)
        let service = SyncStatusService(
            accountStatusProvider: FakeCloudAccountStatusProvider(.available),
            defaults: defaults,
            now: { expectedDate }
        )

        let result = await service.refreshStatus()

        #expect(result.status == .active)
        #expect(result.lastCheckedAt == expectedDate)
        #expect(defaults.object(forKey: SyncStatusService.lastSyncCheckDateKey) as? Date == expectedDate)
    }

    @Test func signedOutStatusStillUpdatesLastCheckDate() async {
        let defaults = UserDefaults(suiteName: "SyncStatusServiceTests.signedOut")!
        defaults.removePersistentDomain(forName: "SyncStatusServiceTests.signedOut")

        let expectedDate = Date(timeIntervalSince1970: 9_999)
        let service = SyncStatusService(
            accountStatusProvider: FakeCloudAccountStatusProvider(.noAccount),
            defaults: defaults,
            now: { expectedDate }
        )

        let result = await service.refreshStatus()

        #expect(result.status == .signedOut)
        #expect(result.lastCheckedAt == expectedDate)
        #expect(defaults.object(forKey: SyncStatusService.lastSyncCheckDateKey) as? Date == expectedDate)
    }

    @Test func providerErrorReturnsErrorStatusAndDoesNotOverwriteDate() async {
        let defaults = UserDefaults(suiteName: "SyncStatusServiceTests.error")!
        defaults.removePersistentDomain(forName: "SyncStatusServiceTests.error")
        let previousDate = Date(timeIntervalSince1970: 42)
        defaults.set(previousDate, forKey: SyncStatusService.lastSyncCheckDateKey)

        let service = SyncStatusService(
            accountStatusProvider: ThrowingCloudAccountStatusProvider(),
            defaults: defaults,
            now: { Date(timeIntervalSince1970: 1000) }
        )

        let result = await service.refreshStatus()

        #expect(result.status == .error)
        #expect(result.lastCheckedAt == previousDate)
        #expect(defaults.object(forKey: SyncStatusService.lastSyncCheckDateKey) as? Date == previousDate)
    }
}

private struct FakeCloudAccountStatusProvider: CloudAccountStatusProviding {
    let status: CKAccountStatus

    init(_ status: CKAccountStatus) {
        self.status = status
    }

    func accountStatus() async throws -> CKAccountStatus {
        status
    }
}

private struct ThrowingCloudAccountStatusProvider: CloudAccountStatusProviding {
    struct StubError: Error {}

    func accountStatus() async throws -> CKAccountStatus {
        throw StubError()
    }
}
