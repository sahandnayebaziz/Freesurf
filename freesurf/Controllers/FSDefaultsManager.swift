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
    private var keyForSpotData = "spotData"
    private var keyForSpotDataTimestamp = "spotDataTimestamp"
    private var lastHourSaved: Int = -1
    
    func saveSpotLibrarySelectionsToDefaults(spotLibrary: SpotLibrary) {
        // save to defaults
        if let defaults = sharedDefaults {
            defaults.setObject(spotLibrary.serializeSpotLibraryToString(), forKey: keyForSavedSpots)
            defaults.synchronize()
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
    
    private func getContextForWatchConnectivity(spotLibrary: SpotLibrary) -> [String:AnyObject] {
        var context: [String: AnyObject] = [:]
        
        context[keyForSavedSpots] = spotLibrary.serializeSpotLibraryToString()
        context[keyForSpotData] = spotLibrary.serializeSpotLibrarySelectionsToData()
        context[keyForSpotDataTimestamp] = NSDate().toString(format: .Custom("dd MMM yyyy HH:mm:ss"))
        
        return context
    }
    
    func saveSpotDataForWatchConnectivity(spotLibrary: SpotLibrary) {
        
        let currentHour = NSDate().hour()
        if currentHour > lastHourSaved {
            // save for watch
            if #available(iOS 9.0, *) {
                if WCSession.isSupported() {
                    let session = WCSession.defaultSession()
                    session.delegate = self
                    session.activateSession()
                    
                    if session.paired && session.watchAppInstalled {
                        let context = getContextForWatchConnectivity(spotLibrary)
                        do {
                            try session.updateApplicationContext(context)
                        }
                        catch {
                            print(error)
                        }
                    }
                }
            }
            
            lastHourSaved = currentHour
            print("updated wtc")
        }
    }
    
    
}