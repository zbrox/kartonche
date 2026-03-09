import TipKit

struct LocationTip: Tip {
    var title: Text {
        Text("Add a Store Location")
    }

    var message: Text? {
        Text("Add a location to your card and it will appear automatically when you're nearby.")
    }

    var image: Image? {
        Image(systemName: "mappin.and.ellipse")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAdded) { $0.donations.count >= 1 }
    }
}
