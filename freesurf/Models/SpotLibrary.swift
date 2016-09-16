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
import AFDateHelper

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
        
        currentHour = Date().hour()
    }
    
    convenience init(serializedSpotLibrary:String) {
        self.init()
        self.deserializeSpotLibraryFromString(serializedSpotLibrary)
    }
    
    // MARK: - Spitcast GET methods -
    func getCountyNames() {
        let dataURL:URL = URL(string: "http://api.spitcast.com/api/spot/all")!
        request(dataURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                guard let httpResponse = response.response else {
                    print("error downloading county names")
                    return
                }
                
                guard let responseData = response.result.value as? Data else {
                    print("error getting data")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: [])
                    
//                    if let nestedDictionary = dictionary["anotherKey"] as? [String: Any]
                    guard let object = jsonData as? [String: Any] else {
                        print("couldn't make object")
                        return
                    }
                    
                    print(object)
                    for _ in 0...object.keys.count {
                        if let nestedSpot = object["1"] as? [String: Any] {
                            print(nestedSpot["county_name"] as? String)
                        }
                    }
                    
                }
        }
//        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//            .validate()
//            .responseJSON { _, _, result in
//                switch result {
//                case .Success:
//                    if result.value != nil {
//                        let json = JSON(result.value!)
//                        let numberOfSpotsInJSONResponse = json.count
//                        for var index = 0; index < numberOfSpotsInJSONResponse; index++ {
//                            if let countyName:String = json[index]["county_name"].string {
//                                self.initializeCountyData(countyName)
//                            }
//                            else {
//                                NSLog("A county name could not be read.")
//                            }
//                        }
//                        self.getSpotsInCounties(self.allCountyNames)
//                    }
//                case .Failure(_, let error):
//                    NSLog("\(error)")
//                }
//        }
    }
    
    func getSpotsInCounties(_ counties:[String]) {
//        var listOfCounties = counties
//        if (!listOfCounties.isEmpty) {
//            let formattedCountyNameForRequest = listOfCounties[0].stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSString.CompareOptions.LiteralSearch, range: nil).lowercased()
//            let dataURL = URL(string: "http://api.spitcast.com/api/county/spots/\(formattedCountyNameForRequest)/")!
//            
//            Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//                .validate()
//                .responseJSON { _, _, result in
//                    switch result {
//                    case .Success:
//                        if result.value != nil {
//                            let json = JSON(result.value!)
//                            let numberOfSpotsInCounty = json.count
//                            
//                            for var index = 0; index < numberOfSpotsInCounty; index++ {
//                                
//                                if let existingSpotID:Int = json[index]["spot_id"].int {
//                                    let name:String = json[index]["spot_name"].string!
//                                    let county:String = listOfCounties[0]
//                                    
//                                    let long = json[index]["longitude"].double!
//                                    let lat = json[index]["latitude"].double!
//                                    let location = CLLocation(latitude: lat, longitude: long)
//                                    
//                                    if !self.allSpotIDs.contains(existingSpotID) {
//                                        self.allSpotIDs.append(existingSpotID)
//                                        self.spotDataByID[existingSpotID] = SpotData(name: name, county: county, location: nil, heights: nil, conditions: nil)
//                                        self.spotDataRequestLog[existingSpotID] = (name:true, county:true, heights:false, conditions:false)
//                                    }
//                                    self.spotDataByID[existingSpotID]?.location = location
//                                }
//                            }
//                        }
//                        
//                        listOfCounties.removeAtIndex(0)
//                        self.getSpotsInCounties(listOfCounties)
//                    case .Failure(_, let error):
//                        NSLog("\(error)")
//                    }
//            }
//        }
//        else {
//            self.allSpotsHaveBeenDownloaded = true
//        }
        
    }
    
    func getSpotHeightsForToday(_ spotID:Int) {
//        let dataURL:URL = URL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")!
//        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//            .validate()
//            .responseJSON { _, _, result in
//                switch result {
//                case .Success:
//                    if result.value != nil {
//                        let json = JSON(result.value!)
//                        
//                        var swellHeightsByHour:[Float] = []
//                        for var index = 0; index < 24; index++ {
//                            if let swellHeight = json[index]["size_ft"].float {
//                                swellHeightsByHour.append(swellHeight)
//                            }
//                        }
//                        if swellHeightsByHour.count > 0 {
//                            self.spotDataByID[spotID]!.heights = swellHeightsByHour
//                        }
//                        else {
//                            self.spotDataByID[spotID]!.heights = nil
//                        }
//                        
//                        if let conditions:String = json[0]["shape_full"].string {
//                            self.spotDataByID[spotID]!.conditions = conditions
//                        }
//                        else {
//                            self.spotDataByID[spotID]!.conditions = nil
//                        }
//                    }
//                    
//                    self.spotDataRequestLog[spotID]!.conditions = true
//                    self.spotDataRequestLog[spotID]!.heights = true
//                    
//                    self.notifyViewOfComplete(spotID)
//                case .Failure(_, let error):
//                    NSLog("\(error)")
//                }
//        }
    }
    
    func getCountyWaterTemp(_ county:String, spotSender: Int?) {
//        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSString.CompareOptions.LiteralSearch, range: nil).lowercased()
//        let dataURL = URL(string: "http://api.spitcast.com/api/county/water-temperature/\(formattedCountyNameForRequest)/")!
//        
//        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//            .validate()
//            .responseJSON { _, _, result in
//                switch result {
//                case .Success:
//                    if result.value != nil {
//                        let json = JSON(result.value!)
//                        if let temp = json["fahrenheit"].int {
//                            self.countyDataByName[county]!.waterTemp = temp
//                        }
//                        else {
//                            self.countyDataByName[county]!.waterTemp = nil
//                        }
//                    }
//                    
//                    self.countyDataRequestLog[county]!.waterTemp = true
//                    
//                    if let spotID = spotSender {
//                        self.notifyViewOfComplete(spotID)
//                    }
//                case .Failure(_, let error):
//                    NSLog("\(error)")
//                }
//        }
    }
    
    
    func getCountyTideForToday(_ county:String, spotSender: Int?) {
//        var tideLevelsForToday:[Float] = []
//        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSString.CompareOptions.LiteralSearch, range: nil).lowercased()
//        let dataURL:URL = URL(string: "http://api.spitcast.com/api/county/tide/\(formattedCountyNameForRequest)/")!
//        
//        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//            .validate()
//            .responseJSON { _, _, result in
//                switch result {
//                case .Success:
//                    if result.value != nil {
//                        let json = JSON(result.value!)
//                        
//                        for var index = 0; index < 24; index++ {
//                            if let tide = json[index]["tide"].float {
//                                tideLevelsForToday.append(tide)
//                            }
//                        }
//                        
//                        if tideLevelsForToday.count > 0 {
//                            self.countyDataByName[county]!.tides = tideLevelsForToday
//                        }
//                    }
//                    
//                    self.countyDataRequestLog[county]!.tides = true
//                    
//                    if let spotID = spotSender {
//                        self.notifyViewOfComplete(spotID)
//                    }
//                case .Failure(_, let error):
//                    NSLog("\(error)")
//                }
//        }
    }
    
    func getCountySwell(_ county:String, spotSender: Int?) {
//        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSString.CompareOptions.LiteralSearch, range: nil).lowercased()
//        let dataURL:URL = URL(string: "http://api.spitcast.com/api/county/swell/\(formattedCountyNameForRequest)/")!
//        
//        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//            .validate()
//            .responseJSON { _, _, result in
//                switch result {
//                case .Success:
//                    if result.value != nil {
//                        let json = JSON(result.value!)
//                        
//                        var allSwellsInThisCounty:[(height:Int, period:Int, direction:String)] = []
//                        let possibleSwellNumberInSpitcastResponse = ["0", "1", "2", "3", "4", "5"]
//                        
//                        for (var index = 0; index < possibleSwellNumberInSpitcastResponse.count; index++) {
//                            
//                            if let directionInDegrees:Int = json[self.currentHour][possibleSwellNumberInSpitcastResponse[index]]["dir"].int {
//                                if let heightInMeters:Float = json[self.currentHour][possibleSwellNumberInSpitcastResponse[index]]["hs"].float {
//                                    if let periodInSeconds:Float = json[self.currentHour][possibleSwellNumberInSpitcastResponse[index]]["tp"].float {
//                                        
//                                        let heightInFeet = self.swellMetersToFeet(heightInMeters)
//                                        let directionInHeading = self.degreesToDirection(directionInDegrees)
//                                        let periodAsInt:Int = Int(periodInSeconds)
//                                        
//                                        allSwellsInThisCounty += [(height:heightInFeet, period:periodAsInt, direction:directionInHeading)]
//                                    }
//                                }
//                            }
//                        }
//                        
//                        if allSwellsInThisCounty.count > 0 {
//                            self.countyDataByName[county]!.swells = allSwellsInThisCounty
//                        }
//                    }
//                    
//                    self.countyDataRequestLog[county]!.swells = true
//                    
//                    if let spotID = spotSender {
//                        self.notifyViewOfComplete(spotID)
//                    }
//                case .Failure(_, let error):
//                    NSLog("\(error)")
//                }
//        }
    }
    
    func getCountyWind(_ county:String, spotSender: Int?) {
//        let formattedCountyNameForRequest = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSString.CompareOptions.LiteralSearch, range: nil).lowercased()
//        let dataURL:URL = URL(string: "http://api.spitcast.com/api/county/wind/\(formattedCountyNameForRequest)/")!
//        
//        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
//            .validate()
//            .responseJSON { _, _, result in
//                switch result {
//                case .Success:
//                    if result.value != nil {
//                        let json = JSON(result.value!)
//                        
//                        if let speed = json[self.currentHour]["speed_mph"].float {
//                            if let direction:String = json[self.currentHour]["direction_text"].string {
//                                let windData = (speedInMPH:Int(speed), direction: direction)
//                                self.countyDataByName[county]!.wind = windData
//                            }
//                        }
//                    }
//                    
//                    self.countyDataRequestLog[county]!.wind = true
//                    
//                    if let spotID = spotSender {
//                        self.notifyViewOfComplete(spotID)
//                    }
//                case .Failure(_, let error):
//                    NSLog("\(error)")
//                }
//        }
    }
    
    // MARK: - Get spot values -
    
    func nameForSpotID(_ id:Int) -> String { return self.spotDataByID[id]!.name }
    func countyForSpotID(_ id:Int) -> String { return self.spotDataByID[id]!.county }
    func locationForSpotID(_ id:Int) -> CLLocation? { return self.spotDataByID[id]!.location }
    
    func heightForSpotIDAtCurrentHour(_ id:Int) -> Int? {
        if let height:Float = self.spotDataByID[id]!.heights?[self.currentHour] {
            return Int(height)
        }
        else {
            return nil
        }
    }
    
    func conditionForSpotID(_ id:Int) -> String? {
        if let conditions:String = self.spotDataByID[id]!.conditions {
            return conditions
        }
        else {
            return nil
        }
    }
    
    func waterTempForSpotID(_ id:Int) -> Int? {
        return self.countyDataByName[self.countyForSpotID(id)]?.waterTemp
    }
    
    func tidesForSpotID(_ id:Int) -> [Float]? { return self.countyDataByName[self.countyForSpotID(id)]!.tides }
    func heightsForSpotID(_ id:Int) -> [Float]? { return self.spotDataByID[id]!.heights }
    func swellsForSpotID(_ id:Int) -> [(height:Int, period:Int, direction:String)]? { return self.countyDataByName[self.countyForSpotID(id)]!.swells }
    func windForSpotID(_ id:Int) -> (speedInMPH:Int, direction:String)? { return self.countyDataByName[self.countyForSpotID(id)]!.wind }
    
    func significantSwellForSpotID(_ id:Int) -> (height:Int, period:Int, direction:String)? {
        if let swells = self.countyDataByName[self.countyForSpotID(id)]!.swells {
            var mostSignificantSwell = swells[0]
            for index in 1 ..< swells.count {
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
    func allSpotCellDataIfRequestsComplete(_ id: Int) -> (height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?)? {
        if let spotRequests = self.spotDataRequestLog[id] {
            if let countyRequests = self.countyDataRequestLog[self.countyForSpotID(id)] {
                if spotRequests.heights && spotRequests.conditions && countyRequests.waterTemp && countyRequests.swells && countyRequests.tides && countyRequests.wind {
                    return (height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id))
                }
            }
        }
        return nil
    }
    
    func allDetailViewData(_ id: Int) -> (name:String, height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?, condition:String?, wind:(speedInMPH:Int, direction:String)?, tides:[Float]?, heights:[Float]?) {
        return (name:self.nameForSpotID(id), height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id), condition:self.conditionForSpotID(id), wind:self.windForSpotID(id), tides:self.tidesForSpotID(id), heights:heightsForSpotID(id))
    }
    
    func notifyViewOfComplete(_ id: Int) {
        if allSpotCellDataIfRequestsComplete(id) != nil {
            delegate?.didDownloadDataForSpot()
        }
    }
    
    // MARK: - SpotLibrary management -
    
    func serializeSpotLibraryToString() -> String {
        var exportString:String = ""
        for spotID in self.selectedSpotIDs {
            exportString += "\(spotID).\(self.nameForSpotID(spotID)).\(self.countyForSpotID(spotID)),"
        }
        return exportString
    }
    
    func deserializeSpotLibraryFromString(_ exportString: String) {
        let listOfSpotExports:[String] = exportString.components(separatedBy: ",")
        for spotExport in listOfSpotExports {
            var spotAttributes:[String] = spotExport.components(separatedBy: ".")
            if spotAttributes.count == 3 {
                let spotID:Int = Int(spotAttributes[0])!
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

    func initializeCountyData(_ countyName:String) {
        if (!self.allCountyNames.contains(countyName)) {
            self.allCountyNames.append(countyName)
            self.countyDataByName[countyName] = (waterTemp:nil, tides:nil, swells:nil, wind:nil)
            self.countyDataRequestLog[countyName] = (waterTemp:false, tides:false, swells:false, wind:false)
        }
    }
    
    // MARK: - SpotLibrary math -
    func swellMetersToFeet(_ height:Float) -> Int { return Int(height * 3.2) }

    func degreesToDirection(_ degrees:Int) -> String {
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





















