//
//  CardListDeepLinkTests.swift
//  kartoncheTests
//
//  Created on 2026-02-21.
//

import Foundation
import Testing
@testable import kartonche

struct CardListDeepLinkTests {
    @Test @MainActor func parsesCardDeepLink() throws {
        let cardID = UUID()
        let url = try #require(URL(string: "kartonche://card?id=\(cardID.uuidString)"))

        let deepLink = CardListDeepLink(url: url)

        switch deepLink {
        case .card(let parsedID):
            #expect(parsedID == cardID)
        default:
            Issue.record("Expected card deep link")
        }
    }

    @Test @MainActor func parsesScanDeepLink() throws {
        let url = try #require(URL(string: "kartonche://scan"))

        let deepLink = CardListDeepLink(url: url)

        switch deepLink {
        case .scan:
            break
        default:
            Issue.record("Expected scan deep link")
        }
    }

    @Test @MainActor func parsesNearbyCardsDeepLink() throws {
        let firstID = UUID()
        let secondID = UUID()
        let url = try #require(URL(string: "kartonche://nearby-cards?ids=\(firstID.uuidString),\(secondID.uuidString)"))

        let deepLink = CardListDeepLink(url: url)

        switch deepLink {
        case .nearbyCards(let ids):
            #expect(ids == [firstID, secondID])
        default:
            Issue.record("Expected nearby-cards deep link")
        }
    }
}
