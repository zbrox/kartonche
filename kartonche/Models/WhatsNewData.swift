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
        version: "2026.02.6",
        features: [
            WhatsNewFeature(
                icon: "camera.viewfinder",
                titleEN: "Quick Scan",
                titleBG: "Бързо сканиране",
                descriptionEN: "Add cards faster by scanning from camera or photo library with automatic barcode and color detection",
                descriptionBG: "По-бързо добавяне на карти чрез сканиране от камера или снимка с автоматично разпознаване на баркод и цвят"
            ),
            WhatsNewFeature(
                icon: "magnifyingglass",
                titleEN: "Spotlight Search",
                titleBG: "Търсене в Spotlight",
                descriptionEN: "Find your loyalty cards from the home screen via Spotlight",
                descriptionBG: "Намерете картите си за лоялност от началния екран чрез Spotlight"
            ),
            WhatsNewFeature(
                icon: "wallet.pass",
                titleEN: "Apple Wallet",
                titleBG: "Apple Wallet",
                descriptionEN: "Add cards to Apple Wallet with on-device pass signing",
                descriptionBG: "Добавяне на карти в Apple Wallet с подписване на пространството на устройството"
            ),
            WhatsNewFeature(
                icon: "eye",
                titleEN: "Quick Look Preview",
                titleBG: "Бърз преглед",
                descriptionEN: "Preview .kartonche files with Quick Look before importing",
                descriptionBG: "Преглед на .kartonche файлове с Бърз преглед преди импортиране"
            ),
            WhatsNewFeature(
                icon: "square.and.arrow.up.on.square",
                titleEN: "Import & Export",
                titleBG: "Импортиране и експортиране",
                descriptionEN: "Revamped data import and export for easy backup and transfer",
                descriptionBG: "Подобрено импортиране и експортиране за лесно архивиране и прехвърляне"
            ),
        ]
    ),
    WhatsNewVersion(
        version: "2026.02.5",
        features: [
            WhatsNewFeature(
                icon: "hand.draw",
                titleEN: "Swipe Actions",
                titleBG: "Действия при плъзгане",
                descriptionEN: "Swipe cards to quickly favorite, edit, or delete",
                descriptionBG: "Плъзнете карти за бързо означаване, редактиране или изтриване"
            ),
            WhatsNewFeature(
                icon: "switch.2",
                titleEN: "Control Center Widgets",
                titleBG: "Инструменти за Контролен център",
                descriptionEN: "Quick access to cards from Control Center",
                descriptionBG: "Бърз достъп до карти от Контролния център"
            ),
            WhatsNewFeature(
                icon: "paintpalette",
                titleEN: "Redesigned Card Display",
                titleBG: "Преработен дизайн на картите",
                descriptionEN: "Cards now display with prominent brand colors",
                descriptionBG: "Картите вече се показват с изявени цветове на марката"
            ),
        ]
    ),
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
