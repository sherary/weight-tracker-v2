//
//  WidgetTrackerBundle.swift
//  WidgetTracker
//
//  Created by Sherary Apriliana on 28/08/26.
//

import WidgetKit
import SwiftUI

@main
struct WidgetTrackerBundle: WidgetBundle {
    var body: some Widget {
        WidgetTracker()
        WidgetTrackerControl()
        WidgetTrackerLiveActivity()
    }
}
