//
//  FSDefaultsManager.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/14/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import WatchConnectivity

class FSDefaultsManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = FSDefaultsManager()
    
    private var sharedDefaults = NSUserDefaults(suiteName: "group.freesurf")
    private var keyForSavedSpots = "userSelectedSpots"
    
    func saveSpotLibrarySelectionsToDefaults(spotLibrary: SpotLibrary) {
        
        // save to defaults
        if let defaults = sharedDefaults {
            defaults.setObject(spotLibrary.serializeSpotLibraryToString(), forKey: keyForSavedSpots)
            defaults.synchronize()
        }
        
        // save for watch
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
                
                if session.paired && session.watchAppInstalled {
                    let context = [keyForSavedSpots: spotLibrary.serializeSpotLibraryToString()]
                    do {
                        try session.updateApplicationContext(context)
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
        
    }
    
    func readSpotLibrarySelectionsFromDefaults() -> String? {
        if let defaults = sharedDefaults {
            if let savedSpots = defaults.objectForKey(keyForSavedSpots) as? String {
                return savedSpots
            }
            defaults.synchronize()
        }
        return nil
    }
}