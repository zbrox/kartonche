//
//  TipStoreTests.swift
//  kartoncheTests
//
//  Created on 2026-03-22.
//

import Testing
import StoreKit
import StoreKitTest
@testable import kartonche

@MainActor
struct TipStoreTests {
    let session: SKTestSession
    let store: TipStore

    init() throws {
        session = try SKTestSession(configurationFileNamed: "TipProducts")
        session.disableDialogs = true
        session.clearTransactions()
        store = TipStore()
    }

    @Test func productIDsContainsAllThreeTiers() {
        #expect(TipStore.productIDs == [
            "com.zbrox.kartonche.app.tip.small",
            "com.zbrox.kartonche.app.tip.medium",
            "com.zbrox.kartonche.app.tip.large",
        ])
    }

    @Test func loadProductsFetchesAllThree() async {
        await store.loadProducts()

        #expect(store.products.count == 3)
        #expect(store.purchaseError == nil)
    }

    @Test func productsSortedByPriceAscending() async {
        await store.loadProducts()

        let prices = store.products.map(\.price)
        #expect(prices == prices.sorted())
    }

    @Test func loadProductsSetsIsLoading() async {
        #expect(store.isLoading == false)
        await store.loadProducts()
        #expect(store.isLoading == false)
    }

    @Test func purchaseCompletesSuccessfully() async throws {
        await store.loadProducts()
        let product = try #require(store.products.first)

        let success = await store.purchase(product)

        #expect(success == true)
        #expect(store.purchaseError == nil)
    }
}
