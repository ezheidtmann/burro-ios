//
//  File.swift
//  Burro
//
//  Created by Evan Heidtmann on 2/4/20.
//  Copyright © 2020 Evan Heidtmann. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class TrackingViewData : ObservableObject {
    @Published var selectedTrackingState = TrackingState.none
    @Published var haveGoodGPSFix = false
}
