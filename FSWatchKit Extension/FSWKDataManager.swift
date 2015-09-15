//
//  FSWKDataManager.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/14/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import WatchConnectivity

class FSWKDataManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = FSWKDataManager()
    
    private var sharedDefaults = NSUserDefaults(suiteName: "group.freesurf")
    private var keyForSavedSpots = "userSelectedSpots"
    
    func readSpotLibrarySelectionsFromDefaults() -> [FSWKSpot]? {
        
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        
        if let savedSpotsAsString = session.receivedApplicationContext[keyForSavedSpots] {
            var savedSpots: [FSWKSpot] = []
            
            for serializedSpot in savedSpotsAsString.componentsSeparatedByString(",") {
                let spotInfo = serializedSpot.componentsSeparatedByString(".")
                if spotInfo.count == 3 {
                    savedSpots.append(FSWKSpot(id: Int(spotInfo[0])!, name: spotInfo[1], county: spotInfo[2]))
                }
            }
            
            return savedSpots
        }
        
        return nil
    }
    
}