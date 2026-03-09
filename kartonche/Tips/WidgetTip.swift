import TipKit

struct HomeScreenWidgetTip: Tip {
    var title: Text {
        Text("Add a Home Screen Widget")
    }

    var message: Text? {
        Text("Access your favorite cards right from your Home Screen.")
    }

    var image: Image? {
        Image(systemName: "square.stack.3d.up.fill")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAdded) { $0.donations.count >= 2 }
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

struct LockScreenWidgetTip: Tip {
    var title: Text {
        Text("Add a Lock Screen Widget")
    }

    var message: Text? {
        Text("See your favorite cards without even unlocking your phone.")
    }

    var image: Image? {
        Image(systemName: "lock.iphone")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAdded) { $0.donations.count >= 3 }
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

struct ControlCenterWidgetTip: Tip {
    var title: Text {
        Text("Add a Control Center Toggle")
    }

    var message: Text? {
        Text("Open your favorite card with a quick tap from Control Center.")
    }

    var image: Image? {
        Image(systemName: "switch.2")
    }

    var rules: [Rule] {
        #Rule(CardEvents.cardAdded) { $0.donations.count >= 4 }
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}
