//
//  LaunchAppControl.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-08.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct LaunchAppControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.zbrox.kartonche.launchApp"
        ) {
            ControlWidgetButton(action: LaunchAppIntent()) {
                Label(String(localized: "Kartonche", comment: "Control widget button label for app launcher"), systemImage: "creditcard.fill")
            }
        }
        .displayName("Launch Kartonche")
        .description("Opens the Kartonche app")
    }
}
