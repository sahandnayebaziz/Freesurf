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
    func didUpdate(forSpot spot: SpotData, county: CountyData)
}

protocol SpotTableViewDelegate {
    func didLoadSavedSpots(spotsFound: Bool)
    func _devDidLoadAllSpots()
}

struct SpotSelectionResponse {
    var didAddSpot: Bool
}

// a SpotLibrary object holds all surf weather data used at runtime.
class SpotLibrary {
    
    // MARK: - Properties -
    var spotDataByID: [Int: SpotData] = [:]
    var countyDataByName: [String: CountyData] = [:]
    var selectedSpotIDs: [Int] = []
    
    let tableViewDelegate: SpotTableViewDelegate?
    let dataDelegate: SpotDataDelegate?
    
    init(delegate: SpotDataDelegate, tableViewDelegate: SpotTableViewDelegate?) {
        self.dataDelegate = delegate
        self.tableViewDelegate = tableViewDelegate
    }
    
    func loadData() {
        let savedSpots = Defaults.getSavedSpots()
        for spot in savedSpots {
            selectedSpotIDs.append(spot.id)
            spotDataByID[spot.id] = spot
            countyDataByName[spot.county] = CountyData(waterTemperature: nil, tides: nil, swells: nil, wind: nil)
        }
        self.tableViewDelegate?.didLoadSavedSpots(spotsFound: !savedSpots.isEmpty)
        
        Spitcast.getAllCountyNames()
            .then { counties -> Promise<[Int: SpotData]> in
                for county in counties {
                    self.countyDataByName[county] = CountyData(waterTemperature: nil, tides: nil, swells: nil, wind: nil)
                }
                return Spitcast.get(allSpotsForCounties: counties)
            }.then { spotMap -> Void in
                self.spotDataByID = spotMap
                self.tableViewDelegate?._devDidLoadAllSpots()
        }
    }
    
    func select(spotWithId newSpotId: Int) -> Promise<SpotSelectionResponse> {
        return Promise { resolve, reject in
            guard !selectedSpotIDs.contains(newSpotId) else {
                return resolve(SpotSelectionResponse(didAddSpot: false))
            }
            
            selectedSpotIDs.append(newSpotId)
            dispatch_to_background_queue {
                Defaults.save(selectedSpots: self.selectedSpotIDs.map({ self.spotDataByID[$0]! }))
            }
            return resolve(SpotSelectionResponse(didAddSpot: true))
        }
    }
    
    func get(dataForSpotId spotId: Int) {
        let data = spotDataByID[spotId]!
        dataDelegate?.didUpdate(forSpot: data, county: countyDataByName[data.county]!)
        // get requests then fire update
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
//    }
    }
//    func allDetailViewData(_ id: Int) -> (name:String, height:Int?, waterTemp:Int?, swell:Swell?, condition:String?, wind:Wind?, tides:[Float]?, heights:[Float]?) {
//        return (name:"", height: self.heightForSpotIDAtCurrentHour(id), waterTemp: self.waterTempForSpotID(id), swell:self.significantSwellForSpotID(id), condition:self.conditionForSpotID(id), wind:self.windForSpotID(id), tides:self.tidesForSpotID(id), heights:heightsForSpotID(id))
//    }
    
    // MARK: - SpotLibrary math -
    func swellMetersToFeet(_ height:Float) -> Int { return Int(height * 3.2) }

    func degreesToDirection(_ degrees:Int) -> String {
        let listOfDirections:[String] = ["N", "NNW", "NW", "WNW", "W", "WSW", "SW", "SSW", "S", "SSE", "SE", "ESE", "E", "ENE", "NE", "NNE", "N"]
        return listOfDirections[((degrees) + (360/16)/2) % 360 / (360/16)]
    }
}





















