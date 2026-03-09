import TipKit

struct ShareTip: Tip {
    var title: Text {
        Text("Share Your Cards")
    }

    var message: Text? {
        Text("Long press a card to share it with friends and family.")
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.up")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAdded) { $0.donations.count >= 1 }
    }
}
