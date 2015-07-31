//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

struct SpotData {
    var name:String
    var county:String
    var location:CLLocation?
    var heights:[Float]?
    var conditions:String?
}

// a SpotLibrary object holds all surf weather data used at runtime.
class SpotLibrary {
    
    // MARK: - Properties -
    var allCountyNames:[String]
    var allSpotIDs:[Int]
    var selectedSpotIDs:[Int]
    var allSpotsHaveBeenDownloaded:Bool = false
    
    var spotDataByID:[Int:SpotData]
    var spotDataRequestLog:[Int:(name:Bool, county:Bool, heights:Bool, conditions:Bool)]
    var countyDataByName:[String:(waterTemp:Int?, tides:[Float]?, swells:[(height:Int, period:Int, direction:String)]?, wind:(speedInMPH:Int, direction:String)?)]
    var countyDataRequestLog:[String:(waterTemp:Bool, tides:Bool, swells:Bool, wind:Bool)]
    
    var currentHour:Int
    var delegate:SpotLibraryDelegate?
    
    
    // MARK: - Initializers -
    init() {
        allCountyNames = []
        allSpotIDs = []
        selectedSpotIDs = []
        
        spotDataByID = [:]
        countyDataByName = [:]
        spotDataRequestLog = [:]
        countyDataRequestLog = [:]
        
        currentHour = NSDate().hour()
    }
    
    convenience init(serializedSpotLibrary:String) {
        self.init()
        self.deserializeSpotLibraryFromString(serializedSpotLibrary)
    }
    
    // MARK: - Spitcast GET methods -
    func getCountyNames() {
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/all")!
        request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonFromSpitcast, error) in
                if jsonFromSpitcast != nil {
                    let json = JSON(jsonFromSpitcast!)
                    let numberOfSpotsInJSONResponse = json.count
                    for var index = 0; index < numberOfSpotsInJSONResponse; index++ {
                        if let countyName:String = json[index]["county_name"].string {
                            self.initializeCountyData(countyName)
                        }
                        else {
                            NSLog("A county name could not be read.")
                        }
                    }
                    self.getSpotsInCounties(self.allCountyNames)
                }
        }
    }
    
    func getSpotsInCounties(counties:[String]) {
        var listOfCounties = counties
        if (!listOfCounties.isEmpty) {
            let formattedCountyNameForRequest = listOfCounties[0].stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
            let dataURL = NSURL(string: "http://api.spitcast.com/api/county/spots/\(formattedCountyNameForRequest)/")!
            
            request(.GET, dataURL, parameters: nil, encoding: .JSON)
                .responseJSON { (request, response, jsonFromSpitcast, error) in
                    if jsonFromSpitcast != nil {
                        let json = JSON(jsonFromSpitcast!)
                        let numberOfSpotsInCounty = json.count
                        
                        for var index = 0; index < numberOfSpotsInCounty; index++ {
                            
                            if let existingSpotID:Int = json[index]["spot_id"].int {
                                let name:String = json[index]["spot_name"].string!
                                let county:String = listOfCounties[0]
                                
                                NSLog("seeing \(name)")
                                
                                let long = json[index]["longitude"].double!
                                let lat = json[index]["latitude"].double!
                                let location = CLLocation(latitude: lat, longitude: long)
                                
                                if !contains(self.allSpotIDs, existingSpotID) {
                                    self.allSpotIDs.append(existingSpotID)
                                    self.spotDataByID[existingSpotID] = SpotData(name: name, county: county, location: nil, heights: nil, conditions: nil)
                                    self.spotDataRequestLog[existingSpotID] = (name:true, county:true, heights:false, conditions:false)
                                }
                                self.spotDataByID[existingSpotID]?.location = location
                            }
                        }
                    }
                    
                    listOfCounties.removeAtIndex(0)
                    self.getSpotsInCounties(listOfCounties)
                    
            }
        }
        else {
            self.allSpotsHaveBeenDownloaded = true
        }
        
    }
    
    func getSpotHeightsForToday(spotID:Int) {
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")!
        request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonFromSpitcast, error) in
                if jsonFromSpitcast != nil {
                    let json = JSON(jsonFromSpitcast!)
                    
                    var swellHeightsByHour:[Float] = []
                    for var index = 0; index < 24; index++ {
                        if let swellHeight = json[index]["size_ft"].float {
                            swellHeightsByHour.append(swellHeight)
                        }
                    }
                    if swellHeightsByHour.count > 0 {
                        self.spotDataByID[spotID]!.heights = swellHeightsByHour
                    }
                    else {
                        self.spotDataByID[spotID]!.heights = nil
                    }
                    
                    var currentConditionsString:String? = nil
                    if let conditions:String = json[0]["shape_full"].string {
                        self.spotDataByID[spotID]!.conditions = conditions
                    }
                    else {
                        self.spotDataByID[spotID]!.conditions = nil
                    }
                }
                
                self.spotDataRequestLog[spotID]!.conditions = true
                self.spotDataRequestLog[spotID]!.heights = true
                
                self.notifyViewOfComplete(spotID)
        }
    }
    
    func getCountyWaterTemp(county:String, spotSender: Int?) {
        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let dataURL = NSURL(string: "http://api.spitcast.com/api/county/water-temperature/\(formattedCountyNameForRequest)/")!
        request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonFromSpitcast, error) in
                if jsonFromSpitcast != nil {
                    let json = JSON(jsonFromSpitcast!)
                    if let temp = json["fahrenheit"].int {
                        self.countyDataByName[county]!.waterTemp = temp
                    }
                    else {
                        self.countyDataByName[county]!.waterTemp = nil
                    }
                }
                
                self.countyDataRequestLog[county]!.waterTemp = true
                
                if let spotID = spotSender {
                    self.notifyViewOfComplete(spotID)
                }
        }
    }
    
    
    func getCountyTideForToday(county:String, spotSender: Int?) {
        var tideLevelsForToday:[Float] = []
        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/tide/\(formattedCountyNameForRequest)/")!
        request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonFromSpitcast, error) in
                if jsonFromSpitcast != nil {
                    let json = JSON(jsonFromSpitcast!)
                    
                    for var index = 0; index < 24; index++ {
                        if let tide = json[index]["tide"].float {
                            tideLevelsForToday.append(tide)
                        }
                    }
                    
                    if tideLevelsForToday.count > 0 {
                        self.countyDataByName[county]!.tides = tideLevelsForToday
                    }
                }
                
                self.countyDataRequestLog[county]!.tides = true
                
                if let spotID = spotSender {
                    self.notifyViewOfComplete(spotID)
                }
        }
    }
    
    func getCountySwell(county:String, spotSender: Int?) {
        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/swell/\(formattedCountyNameForRequest)/")!
        request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonFromSpitcast, error) in
                if jsonFromSpitcast != nil {
                    let json = JSON(jsonFromSpitcast!)
                    
                    var allSwellsInThisCounty:[(height:Int, period:Int, direction:String)] = []
                    let possibleSwellNumberInSpitcastResponse = ["0", "1", "2", "3", "4", "5"]
                    
                    for (var index = 0; index < possibleSwellNumberInSpitcastResponse.count; index++) {
                        
                        if let directionInDegrees:Int = json[self.currentHour][possibleSwellNumberInSpitcastResponse[index]]["dir"].int {
                            if let heightInMeters:Float = json[self.currentHour][possibleSwellNumberInSpitcastResponse[index]]["hs"].float {
                                if let periodInSeconds:Float = json[self.currentHour][possibleSwellNumberInSpitcastResponse[index]]["tp"].float {
                                    
                                    var heightInFeet = self.swellMetersToFeet(heightInMeters)
                                    var directionInHeading = self.degreesToDirection(directionInDegrees)
                                    var periodAsInt:Int = Int(periodInSeconds)
                                    
                                    allSwellsInThisCounty += [(height:heightInFeet, period:periodAsInt, direction:directionInHeading)]
                                }
                            }
                        }
                    }
                    
                    if allSwellsInThisCounty.count > 0 {
                        self.countyDataByName[county]!.swells = allSwellsInThisCounty
                    }
                }
                
                self.countyDataRequestLog[county]!.swells = true
                
                if let spotID = spotSender {
                    self.notifyViewOfComplete(spotID)
                }
        }
        
    }
    
    func getCountyWind(county:String, spotSender: Int?) {
        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/wind/\(formattedCountyNameForRequest)/")!
        request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonFromSpitcast, error) in
                if jsonFromSpitcast != nil {
                    let json = JSON(jsonFromSpitcast!)
                    
                    var speed:Float? = nil
                    var direction:String? = nil
                    
                    if let speed = json[self.currentHour]["speed_mph"].float {
                        if let direction:String = json[self.currentHour]["direction_text"].string {
                            let windData = (speedInMPH:Int(speed), direction: direction)
                            self.countyDataByName[county]!.wind = windData
                        }
                    }
                }
                
                self.countyDataRequestLog[county]!.wind = true
                
                if let spotID = spotSender {
                    self.notifyViewOfComplete(spotID)
                }
        }
    }
    
    // MARK: - Get spot values -
    
    func nameForSpotID(id:Int) -> String { return self.spotDataByID[id]!.name }
    func countyForSpotID(id:Int) -> String { return self.spotDataByID[id]!.county }
    func locationForSpotID(id:Int) -> CLLocation? { return self.spotDataByID[id]!.location }
    
    func heightForSpotIDAtCurrentHour(id:Int) -> Int? {
        if let height:Float = self.spotDataByID[id]!.heights?[self.currentHour] {
            return Int(height)
        }
        else {
            return nil
        }
    }
    
    func conditionForSpotID(id:Int) -> String? {
        if let conditions:String = self.spotDataByID[id]!.conditions {
            return conditions
        }
        else {
            return nil
        }
    }
    
    func waterTempForSpotID(id:Int) -> Int? {
        return self.countyDataByName[self.countyForSpotID(id)]?.waterTemp
    }
    
    func tidesForSpotID(id:Int) -> [Float]? { return self.countyDataByName[self.countyForSpotID(id)]!.tides }
    func heightsForSpotID(id:Int) -> [Float]? { return self.spotDataByID[id]!.heights }
    func swellsForSpotID(id:Int) -> [(height:Int, period:Int, direction:String)]? { return self.countyDataByName[self.countyForSpotID(id)]!.swells }
    func windForSpotID(id:Int) -> (speedInMPH:Int, direction:String)? { return self.countyDataByName[self.countyForSpotID(id)]!.wind }
    
    func significantSwellForSpotID(id:Int) -> (height:Int, period:Int, direction:String)? {
        if let swells = self.countyDataByName[self.countyForSpotID(id)]!.swells {
            var mostSignificantSwell = swells[0]
            for var index = 1; index < swells.count; index++ {
                if swells[index].height > mostSignificantSwell.height {
                    mostSignificantSwell = swells[index]
                }
            }
            return mostSignificantSwell
        }
        else {
            return nil
        }
    }
    
    // MARK: - Get data for view models -
    func allSpotCellDataIfRequestsComplete(id: Int) -> (height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?)? {
        if let spotRequests = self.spotDataRequestLog[id] {
            if let countyRequests = self.countyDataRequestLog[self.countyForSpotID(id)] {
                if spotRequests.heights && spotRequests.conditions && countyRequests.waterTemp && countyRequests.swells && countyRequests.tides && countyRequests.wind {
                    return (height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id))
                }
            }
        }
        return nil
    }
    
    func allDetailViewData(id: Int) -> (name:String, height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?, condition:String?, wind:(speedInMPH:Int, direction:String)?, tides:[Float]?, heights:[Float]?) {
        return (name:self.nameForSpotID(id), height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id), condition:self.conditionForSpotID(id), wind:self.windForSpotID(id), tides:self.tidesForSpotID(id), heights:heightsForSpotID(id))
    }
    
    func notifyViewOfComplete(id: Int) {
        if allSpotCellDataIfRequestsComplete(id) != nil {
            delegate?.didDownloadDataForSpot()
        }
    }
    
    // MARK: - SpotLibrary management -
    
    func serializeSpotLibraryToString() -> String {
        var exportString:String = ""
        for spotID in self.selectedSpotIDs {
            let coordinate = self.locationForSpotID(spotID)!.coordinate
            exportString += "\(spotID).\(self.nameForSpotID(spotID)).\(self.countyForSpotID(spotID)),"
        }
        return exportString
    }
    
    func deserializeSpotLibraryFromString(exportString: String) {
        var listOfSpotExports:[String] = exportString.componentsSeparatedByString(",")
        for spotExport in listOfSpotExports {
            var spotAttributes:[String] = spotExport.componentsSeparatedByString(".")
            if spotAttributes.count == 3 {
                let spotID:Int = spotAttributes[0].toInt()!
                let spotName:String = spotAttributes[1]
                let spotCounty:String = spotAttributes[2]

                self.allSpotIDs.append(spotID)
                self.selectedSpotIDs.append(spotID)
                self.spotDataByID[spotID] = SpotData(name: spotName, county: spotCounty, location: nil, heights: nil, conditions: nil)
                self.spotDataRequestLog[spotID] = (name: true, county: true, heights: false, conditions: false)
                initializeCountyData(spotCounty)
            }
        }
    }

    func initializeCountyData(countyName:String) {
        if (!contains(self.allCountyNames, countyName)) {
            self.allCountyNames.append(countyName)
            self.countyDataByName[countyName] = (waterTemp:nil, tides:nil, swells:nil, wind:nil)
            self.countyDataRequestLog[countyName] = (waterTemp:false, tides:false, swells:false, wind:false)
        }
    }
    
    // MARK: - SpotLibrary math -
    func swellMetersToFeet(height:Float) -> Int { return Int(height * 3.2) }

    func degreesToDirection(degrees:Int) -> String {
        let listOfDirections:[String] = ["N", "NNW", "NW", "WNW", "W", "WSW", "SW", "SSW", "S", "SSE", "SE", "ESE", "E", "ENE", "NE", "NNE", "N"]
        return listOfDirections[((degrees) + (360/16)/2) % 360 / (360/16)]
    }
    
//    func acs(s1:Student, s2:Student) -> Bool {
//        return s1.name < s2.name
//    }
//    func des(s1:Student, s2:Student) -> Bool {
//        return s1.name > s2.name
//    }
//    var n1 = sorted(studentrecord, acs) // Alex, John, Tom
//    var n2 = sorted(studentrecord, des) // Tom, John, Alex
}

// MARK: - Delegate methods -
@objc protocol SpotLibraryDelegate {
    
    func didDownloadDataForSpot()
}





















