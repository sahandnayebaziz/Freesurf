//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SpotLibrary: NSObject, NSURLSessionDelegate {
    var allCountyNames:[String] = []
    var allSpotIDs:[Int] = []
    var selectedSpotIDs:[Int] = []
    var spotDataDictionary:[Int:(spotName:String, spotCounty:String, spotHeights:[Int]?)] = [:]
    var countyDataDictionary:[String:(waterTemp:Int?, tides:[Int]?)] = [:]
    var currentHour:Int = NSDate().hour()
    
    func getCounties() {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/all")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberInData = sourceData!.count
            for var index = 0; index < numberInData; index++ {
                let newSpotCounty:String = sourceData![index]!["county_name"]! as String
                if !(contains(self.allCountyNames, newSpotCounty)) {
                    self.allCountyNames.append(newSpotCounty)
                }
            }
            self.getNextSpots(self.allCountyNames)
        })
        sourceTask.resume()
    }
    
    func getNextSpots(counties:[String]) {
        if counties.count > 0 {
            var county = counties[0]
            let countyString:String = counties[0].stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
            let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/\(countyString)/")!
            var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var sourceData:AnyObject? = nil
            let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
                sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                let numberOfSpotsInCounty = sourceData!.count
                for var index = 0; index < numberOfSpotsInCounty; index++ {
                    let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
                    let newSpotName:String = sourceData![index]!["spot_name"]! as String
                    let newSpotCounty:String = sourceData![index]!["county"]! as String
                    
                    if let existingHeights:[Int] = self.heights(newSpotID) {
                        self.spotDataDictionary[newSpotID] = (newSpotName, newSpotCounty, existingHeights)
                    }
                    else {
                        self.spotDataDictionary[newSpotID] = (newSpotName, newSpotCounty, nil)
                    }
                    
                    if (!contains(self.countyDataDictionary.keys.array, newSpotCounty)) {
                        self.countyDataDictionary[county] = (nil, nil)
                    }
                    self.allSpotIDs.append(newSpotID)
                }
                var newCounties = counties
                newCounties.removeAtIndex(0)
                self.getNextSpots(newCounties)
            })
            sourceTask.resume()
        }
        else {
            NSLog("Downloaded all spots")
        }
    }
    
    func getSpotSwell(spotID:Int) {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberOfHoursReported:Int = sourceData!.count
            var newArrayOfHourHeights:[Int] = []
            for var index = 0; index < numberOfHoursReported; index++ {
                newArrayOfHourHeights.append(sourceData![index]!["size"]! as Int)
            }
            self.spotDataDictionary[spotID]!.spotHeights = newArrayOfHourHeights
        })
        sourceTask.resume()
    }
    
    func getCountyWaterTemp(county:String) {
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/water-temperature/\(countyString)/")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            self.countyDataDictionary[county]!.waterTemp = sourceData!["fahrenheit"]! as Int?
        })
        sourceTask.resume()
    }
    
    func getCountyTide(county:String) {
        let hoursToday:Int = 24 - self.currentHour
        let hoursTomorrow:Int = 24 - hoursToday
        
        var next24HoursOfTides:[Int] = []
        
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/tide/\(countyString)/")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            for var index = self.currentHour; index <= 24; index++ {
                next24HoursOfTides.append(sourceData![index]!["tide"]! as Int)
            }
            
            
            var today = NSDate()
            today = today.dateByAddingDays(1)
            
            let jsonTomorrowParameter:String = today.toString(format: .Custom("yyyyMMdd"))
            let sourceURLTomorrow:NSURL = NSURL(string: "http://api.spitcast.com/api/county/tide/\(countyString)/?dval=" + jsonTomorrowParameter)!
            var sourceSessionTomorrow:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var sourceDataTomorrow:AnyObject? = nil
            let sourceTaskTomorrow = sourceSessionTomorrow.dataTaskWithURL(sourceURLTomorrow, completionHandler: {(data, response, error) -> Void in
                sourceDataTomorrow = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                for var index = 0; index < hoursTomorrow; index++ {
                    next24HoursOfTides.append(sourceDataTomorrow![index]!["tide"]! as Int)
                }
                
                self.countyDataDictionary[county]!.tides = next24HoursOfTides
                
            })
            sourceTaskTomorrow.resume()
            
        })
        sourceTask.resume()
    }
    
    func name(id:Int) -> String { return self.spotDataDictionary[id]!.spotName }
    func county(id:Int) -> String { return self.spotDataDictionary[id]!.spotCounty }
    func heights(id:Int) -> [Int]? { return self.spotDataDictionary[id]?.spotHeights? }
    func heightAtHour(id:Int, hour:Int) -> Int? { return self.spotDataDictionary[id]!.spotHeights?[hour] }
    func waterTemp(id:Int) -> Int? { return self.countyDataDictionary[self.county(id)]!.waterTemp }
    func next24Tides(id:Int) -> [Int]? {
        return self.countyDataDictionary[self.county(id)]!.tides?
    }
    
    
    func exportLibraryToString() -> String {
        var exportString:String = ""
        
        for spotID in self.selectedSpotIDs {
            exportString += "\(spotID).\(name(spotID)).\(county(spotID)),"
        }
        
        return exportString
    }
    
    func initLibraryFromString(exportString: String) {
        var listOfSpotExports:[String] = exportString.componentsSeparatedByString(",")
        for spotExport in listOfSpotExports {
            var spotAttributes:[String] = spotExport.componentsSeparatedByString(".")
            if spotAttributes.count == 3 {
                let spotID:Int = spotAttributes[0].toInt()!
                let spotName:String = spotAttributes[1]
                let spotCounty:String = spotAttributes[2]
                
                self.selectedSpotIDs.append(spotID)
                self.spotDataDictionary[spotID] = (spotName, spotCounty, nil)
                self.countyDataDictionary[spotCounty] = (nil, nil)
            }
        }
    }
}



























