import TipKit

struct SwipeActionsTip: Tip {
    var title: Text {
        Text("Swipe for Quick Actions")
    }

    var message: Text? {
        Text("Swipe a card to favorite or delete it.")
    }

    var image: Image? {
        Image(systemName: "hand.draw.fill")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAdded) { $0.donations.count >= 1 }
    }
}
