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
        kartoncheWidget()
        NearestLocationWidget()
        FavoritesCarouselWidget()
        CircularLockScreenWidget()
        RectangularLockScreenWidget()
    }
}
