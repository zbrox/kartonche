import SwiftUI
import TipKit

#if DEBUG
struct DebugSettingsView: View {
    @AppStorage("debugPreviewAllTips") private var previewAllTips = false

    var body: some View {
        List {
            Section {
                Toggle("Preview All Tips (next launch)", isOn: $previewAllTips)

                Button("Reset Tips History") {
                    try? Tips.resetDatastore()
                }
            } header: {
                Text("TipKit")
            } footer: {
                Text("Preview forces all tips visible on next launch (they won't dismiss until you relaunch again). Reset clears donation history so tips reappear as rules are met.")
            }
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DebugSettingsView()
    }
}
#endif
