//
//  kartoncheWidgetLiveActivity.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct kartoncheWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct kartoncheWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: kartoncheWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension kartoncheWidgetAttributes {
    fileprivate static var preview: kartoncheWidgetAttributes {
        kartoncheWidgetAttributes(name: "World")
    }
}

extension kartoncheWidgetAttributes.ContentState {
    fileprivate static var smiley: kartoncheWidgetAttributes.ContentState {
        kartoncheWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: kartoncheWidgetAttributes.ContentState {
         kartoncheWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: kartoncheWidgetAttributes.preview) {
   kartoncheWidgetLiveActivity()
} contentStates: {
    kartoncheWidgetAttributes.ContentState.smiley
    kartoncheWidgetAttributes.ContentState.starEyes
}
