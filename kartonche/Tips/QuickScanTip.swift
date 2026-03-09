import TipKit

struct QuickScanTip: Tip {
    var title: Text {
        Text("Scan from a Photo")
    }

    var message: Text? {
        Text("Next time, try adding a card by taking a photo or choosing one from your library.")
    }

    var image: Image? {
        Image(systemName: "camera.fill")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAddedManually) { $0.donations.count >= 1 }
    }
}
