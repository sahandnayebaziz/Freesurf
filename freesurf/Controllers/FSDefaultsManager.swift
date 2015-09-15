//
//  FSDefaultsManager.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/14/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation

struct FSDefaultsManager {
    
    private static var sharedDefaults = NSUserDefaults(suiteName: "group.freesurf")
    private static var keyForSavedSpots = "userSelectedSpots"
    
    static func saveSpotLibrarySelectionsToDefaults(spotLibrary: SpotLibrary) {
        if let defaults = sharedDefaults {
            defaults.setObject(spotLibrary.serializeSpotLibraryToString(), forKey: keyForSavedSpots)
            defaults.synchronize()
        }
    }
    
    static func readSpotLibrarySelectionsFromDefaults() -> String? {
        if let defaults = sharedDefaults {
            if let savedSpots = defaults.objectForKey(keyForSavedSpots) as? String {
                return savedSpots
            }
            defaults.synchronize()
        }
        return nil
    }
    
}