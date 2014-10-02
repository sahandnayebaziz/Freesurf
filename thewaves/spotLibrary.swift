//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SpotLibrary: NSObject, NSURLSessionDelegate {
    var countyList:[String] = []
    var allWaveIDs:[Int] = []
    var selectedWaveIDs:[Int] = []
    
    // spotHeight is an optional because it may take longer than expected for the getSwell method to retrieve the height
    var waveDataDictionary:[Int:(spotName:String, spotCounty:String, spotHeight:Int?)] = [:]
    
    override init() {
        super.init()
    }
    
    func getCounties() {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/all")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberInData = sourceData!.count
            for var index = 0; index < numberInData; index++ {
                let newSpotCounty:String = sourceData![index]!["county_name"]! as String
                if !(contains(self.countyList, newSpotCounty)) {
                    self.countyList.append(newSpotCounty)
                    dispatch_to_background_queue {
                        self.getSpots(newSpotCounty)
                    }
                }
            }
        })
        sourceTask.resume()
    }
    
    func getSpots(county:String) {
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/\(countyString)/")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberInData = sourceData!.count
            for var index = 0; index < numberInData; index++ {
                let newSpotName:String = sourceData![index]!["spot_name"]! as String
                let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
                let newSpotCounty:String = sourceData![index]!["county"]! as String
                
                self.waveDataDictionary[newSpotID] = (newSpotName, newSpotCounty, nil)
                self.allWaveIDs.append(newSpotID)
            }
        })
        NSLog("downloaded spots for: \(county)")
        sourceTask.resume()
        
    }
    
    func getSwell(spotID:Int) {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        var newHeightMap:[(spotID:Int, height:Int)] = []
        
        // this line saves a single integer marking the hour of day in 24-hour time ("0", "10", "16")
        var currentHour:Int = NSDate().hour()
        
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            // the json response has 24 hourly forecasts in an array. We use currentHour to select the right one
            let newHeight:Int = sourceData![currentHour]!["size"]! as Int
            
            self.waveDataDictionary[spotID]!.spotHeight = newHeight
        })
        sourceTask.resume()
    }
    
    func name(id:Int) -> String { return self.waveDataDictionary[id]!.spotName }
    func county(id:Int) -> String { return self.waveDataDictionary[id]!.spotCounty }
    func height(id:Int) -> Int? { return self.waveDataDictionary[id]!.spotHeight }
}



























