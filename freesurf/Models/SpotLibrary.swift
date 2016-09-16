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
import PromiseKit

protocol SpotDataDelegate {
    func didLoadSavedSpots(spotsFound: Bool)
    func didUpdate(forSpot spot: SpotData, county: CountyData)
    
    func _devDidLoadAllSpots()
}

// a SpotLibrary object holds all surf weather data used at runtime.
class SpotLibrary {
    
    // MARK: - Properties -
    var allSpotIDs = Set<Int>()
    var selectedSpotIDs: [Int] = []
    
    var spotDataByID: [Int: SpotData] = [:]
    var spotDataRequestLog: [Int:(name:Bool, county:Bool, heights:Bool, conditions:Bool)] = [:]
    var countyDataByName: [String: CountyData] = [:]
    var countyDataRequestLog: [String:(waterTemp:Bool, tides:Bool, swells:Bool, wind:Bool)] = [:]
    
    var currentHour: Int = Date().hour()
    let delegate: SpotDataDelegate
    
    init(delegate: SpotDataDelegate) {
        self.delegate = delegate
        deserializeSpotLibraryFromString()
        
        Spitcast.getAllCountyNames()
        .then { counties -> Promise<[Int: SpotData]> in
            for county in counties {
                self.countyDataByName[county] = CountyData(waterTemperature: nil, tides: nil, swells: nil, wind: nil)
            }
            return Spitcast.get(allSpotsForCounties: counties)
        }.then { spotMap -> Void in
            self.spotDataByID = spotMap
            delegate._devDidLoadAllSpots()
        }
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
        return self.countyDataByName[self.countyForSpotID(id)]?.waterTemperature
    }
    
    func tidesForSpotID(_ id:Int) -> [Float]? { return self.countyDataByName[self.countyForSpotID(id)]!.tides }
    func heightsForSpotID(_ id:Int) -> [Float]? { return self.spotDataByID[id]!.heights }
    func swellsForSpotID(_ id:Int) -> [Swell]? { return self.countyDataByName[self.countyForSpotID(id)]!.swells }
    func windForSpotID(_ id:Int) -> Wind? { return self.countyDataByName[self.countyForSpotID(id)]!.wind }
    
    func significantSwellForSpotID(_ id:Int) -> Swell? {
        guard let swells = self.countyDataByName[self.countyForSpotID(id)]!.swells else {
            return nil
        }
        
        var mostSignificantSwell = swells[0]
        for index in 1 ..< swells.count {
            if swells[index].height > mostSignificantSwell.height {
                mostSignificantSwell = swells[index]
            }
        }
        return mostSignificantSwell
    }
    
    // MARK: - Get data for view models -
    func allSpotCellDataIfRequestsComplete(_ id: Int) -> (height:Int?, waterTemp:Int?, swell:Swell?)? {
        if let spotRequests = self.spotDataRequestLog[id] {
            if let countyRequests = self.countyDataRequestLog[self.countyForSpotID(id)] {
                if spotRequests.heights && spotRequests.conditions && countyRequests.waterTemp && countyRequests.swells && countyRequests.tides && countyRequests.wind {
                    return (height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id))
                }
            }
        }
        return nil
    }
    
    func allDetailViewData(_ id: Int) -> (name:String, height:Int?, waterTemp:Int?, swell:Swell?, condition:String?, wind:Wind?, tides:[Float]?, heights:[Float]?) {
        return (name:self.nameForSpotID(id), height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id), condition:self.conditionForSpotID(id), wind:self.windForSpotID(id), tides:self.tidesForSpotID(id), heights:heightsForSpotID(id))
    }
    
    func notifyViewOfComplete(_ id: Int) {
        if allSpotCellDataIfRequestsComplete(id) != nil {
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
    
    func deserializeSpotLibraryFromString() {
//        guard let exportString = Defaults.getSavedSpots() else {
//            return
//        }
//        
//        let listOfSpotExports:[String] = exportString.components(separatedBy: ",")
//        for spotExport in listOfSpotExports {
//            var spotAttributes:[String] = spotExport.components(separatedBy: ".")
//            if spotAttributes.count == 3 {
//                let spotID:Int = Int(spotAttributes[0])!
//                let spotName:String = spotAttributes[1]
//                let spotCounty:String = spotAttributes[2]
//
//                self.allSpotIDs.insert(spotID)
//                self.selectedSpotIDs.append(spotID)
//                self.spotDataByID[spotID] = SpotData(id: spotID, name: spotName, county: spotCounty, location: nil, heights: nil, conditions: nil)
//                self.spotDataRequestLog[spotID] = (name: true, county: true, heights: false, conditions: false)
//                initializeCountyData(spotCounty)
//            }
//        }
    }

    func initializeCountyData(_ countyName:String) {
//            self.countyDataByName[countyName] = CountyData(waterTemperature: nil, tides: nil, swells: nil, wind: nil)
//            self.countyDataRequestLog[countyName] = (waterTemp:false, tides:false, swells:false, wind:false)
    }
    
    // MARK: - SpotLibrary math -
    func swellMetersToFeet(_ height:Float) -> Int { return Int(height * 3.2) }

    func degreesToDirection(_ degrees:Int) -> String {
        let listOfDirections:[String] = ["N", "NNW", "NW", "WNW", "W", "WSW", "SW", "SSW", "S", "SSE", "SE", "ESE", "E", "ENE", "NE", "NNE", "N"]
        return listOfDirections[((degrees) + (360/16)/2) % 360 / (360/16)]
    }
}





















