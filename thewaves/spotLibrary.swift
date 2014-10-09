//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SpotLibrary: NSObject, NSURLSessionDelegate {
    var spotDataDictionary:[Int:(spotName:String, spotCounty:String, spotHeight:[Int]?)] = [:]
    var countyDataDictionary:[String:(waterTemp:Int?, tide:Int?)] = [:]
    var allSpotIDs:[Int] = []
    var selectedSpotIDs:[Int] = []
    var allCountyNames:[String] = []

    func getCounties() {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/all")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberInData = sourceData!.count
            for var index = 0; index < numberInData; index++ {
                let newSpotCounty:String = sourceData![index]!["county_name"]! as String
                if !(contains(self.allCountyNames, newSpotCounty)) {
                    self.allCountyNames.append(newSpotCounty)
                    dispatch_to_background_queue {
                        self.getSpots(newSpotCounty)
                    }
                }
            }
            NSLog("downloaded all counties")
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
            let numberOfSpotsInCounty = sourceData!.count
            for var index = 0; index < numberOfSpotsInCounty; index++ {
                let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
                let newSpotName:String = sourceData![index]!["spot_name"]! as String
                let newSpotCounty:String = sourceData![index]!["county"]! as String
                
                self.spotDataDictionary[newSpotID] = (newSpotName, newSpotCounty, nil)
                self.countyDataDictionary[county] = (nil, nil)
                self.allSpotIDs.append(newSpotID)
            }
        })
        sourceTask.resume()
    }
    
    func getSpotSwell(spotID:Int) {
        NSLog("called getSpotSwell with id: \(spotID)")
        
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        // var currentHour:Int = NSDate().hour() // this line saves a single integer marking the hour of day in 24-hour time ("0", "10", "16")
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberOfHoursReported:Int = sourceData!.count
            var newArrayOfHourHeights:[Int] = []
            for var index = 0; index < numberOfHoursReported; index++ {
                newArrayOfHourHeights.append(sourceData![index]!["size"]! as Int)
            }
            self.spotDataDictionary[spotID]!.spotHeight = newArrayOfHourHeights
        })
        sourceTask.resume()
    }
    
    func getCountyWaterTemp(county:String) {
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/water-temperature/\(countyString)/")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            self.countyDataDictionary[county]!.waterTemp = sourceData!["fahrenheit"]! as Int?
        })
        sourceTask.resume()
    }
    
    func name(id:Int) -> String { return self.spotDataDictionary[id]!.spotName }
    func county(id:Int) -> String { return self.spotDataDictionary[id]!.spotCounty }
    func heightAtHour(id:Int, hour:Int) -> Int? { return self.spotDataDictionary[id]!.spotHeight?[hour] }
    func waterTemp(id:Int) -> Int? { return self.countyDataDictionary[self.county(id)]!.waterTemp }
}



























