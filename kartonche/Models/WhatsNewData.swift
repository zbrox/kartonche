// What's New data
// Edit this file to update release notes shown in the app

import Foundation

struct WhatsNewFeature {
    let icon: String
    let titleEN: String
    let titleBG: String
    let descriptionEN: String
    let descriptionBG: String
    
    var localizedTitle: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return lang == "bg" ? titleBG : titleEN
    }
    
    var localizedDescription: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return lang == "bg" ? descriptionBG : descriptionEN
    }
}

struct WhatsNewVersion {
    let version: String
    let features: [WhatsNewFeature]
}

// MARK: - Release Notes

let whatsNewVersions: [WhatsNewVersion] = [
    WhatsNewVersion(
        version: "2026.02.4",
        features: [
            WhatsNewFeature(
                icon: "info.circle",
                titleEN: "About & What's New",
                titleBG: "Относно и Какво ново",
                descriptionEN: "Learn about new features and app info",
                descriptionBG: "Научете за новите функции и информация за приложението"
            ),
            WhatsNewFeature(
                icon: "note.text",
                titleEN: "Collapsible Notes",
                titleBG: "Сгъваеми бележки",
                descriptionEN: "Tap to expand or collapse card notes",
                descriptionBG: "Докоснете за разгъване или свиване на бележките"
            ),
            WhatsNewFeature(
                icon: "flag",
                titleEN: "Merchant Country Flags",
                titleBG: "Флагове на държави",
                descriptionEN: "See which country merchants are from",
                descriptionBG: "Вижте от коя държава са търговците"
            ),
        ]
    ),
    WhatsNewVersion(
        version: "2026.02.3",
        features: [
            WhatsNewFeature(
                icon: "location.fill",
                titleEN: "Location Features",
                titleBG: "Функции за местоположение",
                descriptionEN: "Get notified when near your saved stores",
                descriptionBG: "Известия при близост до запазени магазини"
            ),
            WhatsNewFeature(
                icon: "square.grid.2x2",
                titleEN: "Widgets",
                titleBG: "Инструменти",
                descriptionEN: "Quick access from home and lock screen",
                descriptionBG: "Бърз достъп от началния и заключен екран"
            ),
            WhatsNewFeature(
                icon: "bell.badge",
                titleEN: "Expiration Reminders",
                titleBG: "Напомняния за изтичане",
                descriptionEN: "Never miss a card renewal",
                descriptionBG: "Никога не пропускайте подновяване на карта"
            ),
            WhatsNewFeature(
                icon: "square.and.arrow.up",
                titleEN: "Export & Share",
                titleBG: "Експортиране и споделяне",
                descriptionEN: "Share cards via AirDrop",
                descriptionBG: "Споделяне на карти чрез AirDrop"
            ),
        ]
    ),
]
