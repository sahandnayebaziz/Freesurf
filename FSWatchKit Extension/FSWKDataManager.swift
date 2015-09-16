//
//  FSWKDataManager.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/14/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import WatchConnectivity
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
        
        if let data = context[keyForSpotDataTimestamp] as? String {
            let date = NSDate(fromString: data, format: .Custom("dd MMM yyyy HH:mm:ss"))
            if NSDate().hoursAfterDate(date) > 0 {
                // context is more than 0 hours old, load new
            } else {
                // context is not more than 0 hours old, load old
                
                if let serializedSpotDataObjects = context[keyForSpotData] as? [NSData] {
                    var savedSpots: [SpotData] = []
                    for serializedSpot in serializedSpotDataObjects {
                        savedSpots.append(SpotData(serialized: serializedSpot))
                        print(SpotData(serialized: serializedSpot))
                    }
                    return savedSpots
                }
            }
        }
        
        return nil
    }
    
    func downloadHeightForSpotWithId(id: Int, delegate: FSWKDataDelegate) {
        
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(id)")!
        print("requesting \(id)")
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .validate()
            .responseJSON { _, _, result in
                switch result {
                case .Success:
                    if result.value != nil {
                        let json = JSON(result.value!)
                        let currentHour = NSDate().hour()
                        
                        if let swellHeight = json[currentHour]["size_ft"].int {
                            delegate.didDownloadSpotData(FSWKSpotData(id: id, height: swellHeight))
                        }
                            
                    }
                case .Failure(_, let error):
                    NSLog("\(error)")
                }
        }
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
    }
}