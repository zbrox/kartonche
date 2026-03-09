import Testing
import TipKit
@testable import kartonche

@MainActor
struct TipTests {

    init() async throws {
        try? Tips.resetDatastore()
        try? Tips.configure([.displayFrequency(.immediate)])
    }

    // MARK: - Tip definitions

    @Test func quickScanTipHasContent() {
        let tip = QuickScanTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
    }

    @Test func swipeActionsTipHasContent() {
        let tip = SwipeActionsTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
    }

    @Test func homeScreenWidgetTipHasContent() {
        let tip = HomeScreenWidgetTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
        #expect(tip.image != nil)
    }

    @Test func lockScreenWidgetTipHasContent() {
        let tip = LockScreenWidgetTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
        #expect(tip.image != nil)
    }

    @Test func controlCenterWidgetTipHasContent() {
        let tip = ControlCenterWidgetTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
        #expect(tip.image != nil)
    }

    @Test func locationTipHasContent() {
        let tip = LocationTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
        #expect(tip.image != nil)
    }

    @Test func shareTipHasContent() {
        let tip = ShareTip()
        #expect(String(describing: tip.title) != "")
        #expect(tip.message != nil)
        #expect(tip.image != nil)
    }

    // MARK: - Event donation

    @Test func cardEventsCanBeDonated() async throws {
        CardEvents.cardAdded.sendDonation()
        CardEvents.cardAddedManually.sendDonation()
        try await Task.sleep(for: .milliseconds(100))
    }
}
