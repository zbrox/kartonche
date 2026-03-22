//
//  TipStore.swift
//  kartonche
//
//  Created on 2026-03-22.
//

import StoreKit

@MainActor
@Observable
final class TipStore {
    static let productIDs: [String] = [
        "com.zbrox.kartonche.app.tip.small",
        "com.zbrox.kartonche.app.tip.medium",
        "com.zbrox.kartonche.app.tip.large",
    ]

    var products: [Product] = []
    var isLoading = false
    var purchaseError: String?

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await Product.products(for: Self.productIDs)
            products = fetched.sorted { $0.price < $1.price }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Returns true if the purchase completed successfully.
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
