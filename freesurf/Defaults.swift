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
    
    static func save(stringWithSavedSpots string: String) {
//        userDefaults
    }
    
    static func getSavedSpots() -> String? {
        return userDefaults.string(forKey: keyForSavedSpots)
    }
}
