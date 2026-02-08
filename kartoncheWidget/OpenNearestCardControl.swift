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
                Label(String(localized: "Nearest Store", comment: "Control widget button label for opening card of nearest store"), systemImage: "location.fill")
            }
        }
        .displayName("Nearest Store Card")
        .description("Opens card for nearest store location")
    }
}
