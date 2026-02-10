//
//  WalletPassConfiguration.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import Foundation

enum WalletPassConfiguration {
    static let passTypeIdentifier = "pass.com.zbrox.kartonche"
    static let teamIdentifier: String = {
        guard let id = Bundle.main.infoDictionary?["TeamIdentifier"] as? String, !id.isEmpty else {
            fatalError("TeamIdentifier not found in Info.plist — check DEVELOPMENT_TEAM in build settings")
        }
        return id
    }()
    static let organizationName = "kartonche"

    static let certificateResource = "pass-certificate"
    static let privateKeyResource = "pass-key"
    static let wwdrCertificateResource = "wwdr"

    /// Maps bundle resource name → pass archive filename (without extension).
    /// The archive names are mandated by the Apple Wallet pass format.
    static let iconAssets: [(resource: String, archiveName: String)] = [
        ("pass-icon", "icon"),
        ("pass-icon@2x", "icon@2x"),
        ("pass-icon@3x", "icon@3x"),
    ]

    /// Logo assets have their white background stripped at generation time.
    static let logoAssets: [(resource: String, archiveName: String)] = [
        ("pass-logo", "logo"),
        ("pass-logo@2x", "logo@2x"),
        ("pass-logo@3x", "logo@3x"),
    ]
}
