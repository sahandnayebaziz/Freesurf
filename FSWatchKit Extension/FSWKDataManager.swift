//
//  FSWKDataManager.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/14/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import WatchConnectivity
import PromiseKit

protocol FSWKDataDelegate {
    func didDownloadSpotData(data: FSWKSpotData) -> Void
}

class FSWKDataManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = FSWKDataManager()
    
    private var sharedDefaults = NSUserDefaults(suiteName: "group.freesurf")
    private var keyForSavedSpots = "userSelectedSpots"
    private var keyForSpotData = "spotData"
    private var keyForSpotDataTimestamp = "spotDataTimestamp"
    
    func readSpotLibrarySelectionsFromDefaults() -> [SpotData]? {
        
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        
        let context = session.receivedApplicationContext
        
        if let data = context[keyForSpotDataTimestamp] as? String, let serializedSpotDataObjects = context[keyForSpotData] as? [NSData] {
            var savedSpots: [SpotData] = []
            
            let date = NSDate(fromString: data, format: .Custom("dd MMM yyyy HH:mm:ss"))
            if date.isToday() {
                for serializedSpot in serializedSpotDataObjects {
                    savedSpots.append(SpotData(serialized: serializedSpot))
                }
            }
            else {
                for serializedSpot in serializedSpotDataObjects {
                    let old = SpotData(serialized: serializedSpot)
                    let new = SpotData(id: old.id, name: old.name, county: old.county, location: old.location, heights: nil, conditions: nil)
                    savedSpots.append(new)
                }
            }
            
            return savedSpots
        }
        
        return nil
    }
    
    func downloadData(id: Int) -> Promise<Int> {
        return Promise { fulfill, reject in
            
            let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(id)")!
            request(.GET, dataURL, parameters: nil, encoding: .JSON)
                .validate()
                .responseJSON { _, _, result in
                    switch result {
                    case .Success:
                        if result.value != nil {
                            let json = JSON(result.value!)
                            let currentHour = NSDate().hour()
                            
                            if let swellHeight = json[currentHour]["size_ft"].int {
                                fulfill(swellHeight)
                            }
                            
                        }
                    case .Failure(_, let error):
                        reject(error)
                    }
            }
            
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
        }
    }
    
}