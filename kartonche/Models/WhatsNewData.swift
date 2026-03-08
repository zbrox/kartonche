// What's New data
// Edit this file to update release notes shown in the app

import Foundation

struct WhatsNewFeature {
    let icon: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource
}

struct WhatsNewVersion {
    let version: String
    let features: [WhatsNewFeature]
}

// MARK: - Release Notes

let whatsNewVersions: [WhatsNewVersion] = [
    WhatsNewVersion(
        version: "2026.03.1",
        features: [
            WhatsNewFeature(
                icon: "icloud",
                title: "whats_new.2026_03_1.icloud_sync.title",
                description: "whats_new.2026_03_1.icloud_sync.description"
            ),
            WhatsNewFeature(
                icon: "barcode",
                title: "whats_new.2026_03_1.ean13_support.title",
                description: "whats_new.2026_03_1.ean13_support.description"
            ),
        ]
    ),
    WhatsNewVersion(
        version: "2026.02.6",
        features: [
            WhatsNewFeature(
                icon: "camera.viewfinder",
                title: "whats_new.2026_02_6.quick_scan.title",
                description: "whats_new.2026_02_6.quick_scan.description"
            ),
            WhatsNewFeature(
                icon: "magnifyingglass",
                title: "whats_new.2026_02_6.spotlight_search.title",
                description: "whats_new.2026_02_6.spotlight_search.description"
            ),
            WhatsNewFeature(
                icon: "wallet.pass",
                title: "whats_new.2026_02_6.apple_wallet.title",
                description: "whats_new.2026_02_6.apple_wallet.description"
            ),
            WhatsNewFeature(
                icon: "eye",
                title: "whats_new.2026_02_6.quick_look_preview.title",
                description: "whats_new.2026_02_6.quick_look_preview.description"
            ),
            WhatsNewFeature(
                icon: "square.and.arrow.up.on.square",
                title: "whats_new.2026_02_6.import_export.title",
                description: "whats_new.2026_02_6.import_export.description"
            ),
        ]
    ),
    WhatsNewVersion(
        version: "2026.02.5",
        features: [
            WhatsNewFeature(
                icon: "hand.draw",
                title: "whats_new.2026_02_5.swipe_actions.title",
                description: "whats_new.2026_02_5.swipe_actions.description"
            ),
            WhatsNewFeature(
                icon: "switch.2",
                title: "whats_new.2026_02_5.control_center_widgets.title",
                description: "whats_new.2026_02_5.control_center_widgets.description"
            ),
            WhatsNewFeature(
                icon: "paintpalette",
                title: "whats_new.2026_02_5.redesigned_card_display.title",
                description: "whats_new.2026_02_5.redesigned_card_display.description"
            ),
        ]
    ),
    WhatsNewVersion(
        version: "2026.02.4",
        features: [
            WhatsNewFeature(
                icon: "info.circle",
                title: "whats_new.2026_02_4.about_whats_new.title",
                description: "whats_new.2026_02_4.about_whats_new.description"
            ),
            WhatsNewFeature(
                icon: "note.text",
                title: "whats_new.2026_02_4.collapsible_notes.title",
                description: "whats_new.2026_02_4.collapsible_notes.description"
            ),
            WhatsNewFeature(
                icon: "flag",
                title: "whats_new.2026_02_4.merchant_country_flags.title",
                description: "whats_new.2026_02_4.merchant_country_flags.description"
            ),
        ]
    ),
    WhatsNewVersion(
        version: "2026.02.3",
        features: [
            WhatsNewFeature(
                icon: "location.fill",
                title: "whats_new.2026_02_3.location_features.title",
                description: "whats_new.2026_02_3.location_features.description"
            ),
            WhatsNewFeature(
                icon: "square.grid.2x2",
                title: "whats_new.2026_02_3.widgets.title",
                description: "whats_new.2026_02_3.widgets.description"
            ),
            WhatsNewFeature(
                icon: "bell.badge",
                title: "whats_new.2026_02_3.expiration_reminders.title",
                description: "whats_new.2026_02_3.expiration_reminders.description"
            ),
            WhatsNewFeature(
                icon: "square.and.arrow.up",
                title: "whats_new.2026_02_3.export_share.title",
                description: "whats_new.2026_02_3.export_share.description"
            ),
        ]
    ),
]
