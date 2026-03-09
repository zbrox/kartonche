import TipKit

nonisolated enum CardEvents {
    static let cardAdded = Tips.Event(id: "cardAdded")
    static let cardAddedManually = Tips.Event(id: "cardAddedManually")
}
