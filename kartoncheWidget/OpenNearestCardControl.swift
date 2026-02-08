//
//  OpenNearestCardControl.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-08.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct OpenNearestCardControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.zbrox.kartonche.openNearestCard"
        ) {
            ControlWidgetButton(action: OpenNearestCardIntent()) {
                Label("Nearest Store", systemImage: "location.fill")
            }
        }
        .displayName("Open Nearest Card")
        .description("Opens card for the nearest store")
    }
}
