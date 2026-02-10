//
//  kartoncheWidgetBundle.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import WidgetKit
import SwiftUI

@main
struct kartoncheWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Home screen widgets
        kartoncheWidget()
        NearestLocationWidget()
        FavoritesCarouselWidget()
        
        // Lock screen widgets
        CircularLockScreenWidget()
        RectangularLockScreenWidget()
        InlineLockScreenWidget()
        
        // Control widgets (iOS 18+)
        if #available(iOS 18.0, *) {
            OpenFavoriteCardControl()
            OpenNearestCardControl()
            LaunchAppControl()
        }
    }
}
