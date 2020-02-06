//
//  TrackingStateEnum.swift
//  Burro
//
//  Created by Evan Heidtmann on 2/1/20.
//  Copyright © 2020 Evan Heidtmann. All rights reserved.
//

import Foundation

enum TrackingState: Int {
    case none = 0
    case toPickup
    case toDelivery
    
    func shouldTrackLocations() -> Bool {
//        return true
        return [TrackingState.toPickup, TrackingState.toDelivery].contains(self)
    }
    
    func saveToUserDefaults() {
        UserDefaults.standard.set(self.rawValue, forKey: "TrackingState")
    }
    
    static func getFromUserDefaults() -> TrackingState {
        let defaults = UserDefaults.standard
        let rawState = defaults.integer(forKey: "TrackingState")
        return TrackingState(rawValue: rawState) ?? TrackingState.none
    }
}
