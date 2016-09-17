//
//  Defaults.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/16/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit

struct Defaults {
    
    private static var userDefaults = UserDefaults.standard
    private static var keyForSavedSpots = "userSelectedSpots"
    
    static func save(selectedSpots spots: [SpotData]) {
        var serialized = ""
        for spot in spots {
            serialized += "\(spot.id).\(spot.name).\(spot.county),"
        }
        userDefaults.set(serialized, forKey: keyForSavedSpots)
        NSLog("updated saved spots")
    }
    
    static func getSavedSpots() -> [SpotData] {
        guard let serialized = userDefaults.string(forKey: keyForSavedSpots) else {
            return []
        }
        
        var spots: [SpotData] = []
        
        let spotsSerialized = serialized.components(separatedBy: ",")
        for spot in spotsSerialized {
            let spotAttributes = spot.components(separatedBy: ".")
            if spotAttributes.count == 3 {
                spots.append(SpotData(id: Int(spotAttributes[0])!, name: spotAttributes[1], county: spotAttributes[2], location: nil, heights: nil, conditions: nil))
            }
        }
        
        return spots
    }
}
