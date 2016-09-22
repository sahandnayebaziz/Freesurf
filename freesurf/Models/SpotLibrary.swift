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
    func did(updateSpot spot: SpotData)
    func did(updateCounty county: CountyData)
}

protocol SpotTableViewDelegate {
    func didLoadSavedSpots(spotsFound: Bool)
}

struct SpotSelectionResponse {
    var didAddSpot: Bool
}

class SpotLibrary {
    
    var spotDataByID: [Int: SpotData] = [:]
    var countyDataByName: [String: CountyData] = [:]
    var selectedSpotIDs: [Int] = []
    
    let tableViewDelegate: SpotTableViewDelegate?
    let dataDelegate: SpotDataDelegate?
    
    init(dataDelegate: SpotDataDelegate, tableViewDelegate: SpotTableViewDelegate?) {
        self.dataDelegate = dataDelegate
        self.tableViewDelegate = tableViewDelegate
    }
    
    func loadData() {
        let savedSpots = Defaults.getSavedSpots()
        for spot in savedSpots {
            selectedSpotIDs.append(spot.id)
            spotDataByID[spot.id] = spot
            countyDataByName[spot.county] = CountyData(name: spot.county, waterTemperature: nil, tides: nil, swells: nil, winds: nil)
        }
        dispatch_to_background_queue {
            self.get(dataForSpots: savedSpots)
        }
        self.tableViewDelegate?.didLoadSavedSpots(spotsFound: !savedSpots.isEmpty)
        
        Spitcast.getAllCountyNames()
            .then { counties -> Promise<[Int: SpotData]> in
                for name in counties {
                    if !self.countyDataByName.keys.contains(name) {
                        self.countyDataByName[name] = CountyData(name: name, waterTemperature: nil, tides: nil, swells: nil, winds: nil)
                    }
                }
                return Spitcast.get(allSpotsForCounties: counties)
            }.then { spotMap -> Void in
                for key in spotMap.keys {
                    if !self.spotDataByID.keys.contains(key) {
                        self.spotDataByID[key] = spotMap[key]
                    }
                }
            }.recover { error -> Void in
                print("Error in initial sequence")
                print(error)
        }
    }
    
    func select(spotWithId newSpotId: Int) -> Promise<SpotSelectionResponse> {
        return Promise { resolve, reject in
            guard !selectedSpotIDs.contains(newSpotId) else {
                return resolve(SpotSelectionResponse(didAddSpot: false))
            }
            
            selectedSpotIDs.append(newSpotId)
            saveSelectedSpotsToDefaults()
            return resolve(SpotSelectionResponse(didAddSpot: true))
        }
    }
    
    func delete(spotAtIndex index: Int) {
        selectedSpotIDs.remove(at: index)
        saveSelectedSpotsToDefaults()
    }
    
    func get(dataForSpotId spotId: Int) {
        get(spotDataForSpotId: spotId)
        get(countyDataForCounty: spotDataByID[spotId]!.county)
    }
    
    func saveSelectedSpotsToDefaults() {
        dispatch_to_background_queue {
            Defaults.save(selectedSpots: self.selectedSpotIDs.map({ self.spotDataByID[$0]! }))
        }
    }
    
    private func get(spotDataForSpotId spotId: Int) {
        let spot = spotDataByID[spotId]!
        if spot.heights == nil {
            Spitcast.get(heightsAndConditionsForSpot: spotId)
            .then { response -> Void in
                dispatch_to_main_queue {
                    let spot = self.spotDataByID[response.id]!
                    let updatedSpot = SpotData(id: spot.id, name: spot.name, county: spot.county, location: spot.location, heights: response.heights, conditions: response.conditions)
                    self.spotDataByID[response.id] = updatedSpot
                    self.dataDelegate?.did(updateSpot: self.spotDataByID[response.id]!)
                }
            }.recover { error -> Void in
                print(error)
            }
        }
    }
    
    private func get(countyDataForCounty county: String) {
        let county = countyDataByName[county]!
        if county.waterTemperature == nil {
            Spitcast.get(waterTemperatureForCounty: county.name)
            .then { response -> Void in
                dispatch_to_main_queue {
                    let county = self.countyDataByName[response.county]!
                    let updatedCounty = CountyData(name: county.name, waterTemperature: response.waterTemperature, tides: county.tides, swells: county.swells, winds: county.winds)
                    self.update(countyDataWith: updatedCounty)
                }
            }.recover { error -> Void in
                NSLog("\(error) in water temperature for county.")
            }
        }
        
        if county.tides == nil {
            Spitcast.get(tidesForCounty: county.name)
            .then { response -> Void in
                dispatch_to_main_queue {
                    let county = self.countyDataByName[response.county]!
                    let updatedCounty = CountyData(name: county.name, waterTemperature: county.waterTemperature, tides: response.tides, swells: county.swells, winds: county.winds)
                    self.update(countyDataWith: updatedCounty)
                }
            }.recover { error -> Void in
                NSLog("\(error) in tide for county.")
            }
        }
        
        if county.swells == nil {
            Spitcast.get(swellsForCounty: county.name)
            .then { response -> Void in
                let county = self.countyDataByName[response.county]!
                let updatedCounty = CountyData(name: county.name, waterTemperature: county.waterTemperature, tides: county.tides, swells: response.swells, winds: county.winds)
                self.update(countyDataWith: updatedCounty)
            }.recover { error -> Void in
                NSLog("\(error) in swells for county.")
            }
        }
        
        if county.winds == nil {
            Spitcast.get(windsForCounty: county.name)
                .then { response -> Void in
                    let county = self.countyDataByName[response.county]!
                    let updatedCounty = CountyData(name: county.name, waterTemperature: county.waterTemperature, tides: county.tides, swells: county.swells, winds: response.winds)
                    self.update(countyDataWith: updatedCounty)
                }.recover { error -> Void in
                    NSLog("\(error) in swells for county.")
            }
        }
    }
    
    private func update(countyDataWith county: CountyData) {
        countyDataByName[county.name] = county
        dataDelegate?.did(updateCounty: countyDataByName[county.name]!)
    }
    
    private func get(dataForSpots spots: [SpotData]) {
        
        var counties = Set<String>()
        
        for spot in spots {
            counties.insert(spot.county)
            dispatch_to_background_queue {
                self.get(spotDataForSpotId: spot.id)
            }
        }
        
        for county in counties {
            dispatch_to_background_queue {
                self.get(countyDataForCounty: county)
            }
        }
        
    }
}





















