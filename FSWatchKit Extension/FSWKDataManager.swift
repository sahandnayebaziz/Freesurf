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
import Alamofire

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
    
    enum FreesurfError: ErrorType {
        case DownloadFailed
    }
    
    func downloadData(id: Int) -> Promise<Int> {
        return Promise { fulfill, reject in
            
            let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(id)")!
            Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
                .validate()
                .responseJSON { response in
                    if let data = response.result.value {
                        let json = JSON(data)
                        let currentHour = NSDate().hour()
                        
                        if let swellHeight = json[currentHour]["size_ft"].int {
                            fulfill(swellHeight)
                        }
                    } else {
                        if let error = response.result.error {
                            reject(error)
                        } else {
                            reject(FreesurfError.DownloadFailed)
                        }
                    }
            }
            
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
        }
    }
    
}