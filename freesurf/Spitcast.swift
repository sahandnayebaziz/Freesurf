//
//  Spitcast.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/16/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

enum SpitcastError: Error {
    case BadResponse, BadData
}

struct SpotDownloadResponse {
    var data: [SpotData]
}

struct Spitcast {
    private static let spitcastURL = "http://api.spitcast.com/api"
    
    private static func format(stringForAPI string: String) -> String {
        return string.replacingOccurrences(of: " ", with: "-").lowercased()
    }
    
    static func getAllCountyNames() -> Promise<Set<String>> {
        return Promise { resolve, reject in
            
            request(spitcastURL + "/spot/all", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseData { response in
                    guard let httpResponse = response.response, let responseData = response.result.value else {
                        return reject(SpitcastError.BadResponse)
                    }
                    
                    if httpResponse.statusCode == 200 {
                        let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: [])
                        guard let array = jsonData as? [Any] else {
                            return reject(SpitcastError.BadData)
                        }
                        
                        var names = Set<String>()
                        for item in array {
                            if let nestedCounty = item as? [String: Any] {
                                if let countyName = nestedCounty["county_name"] as? String {
                                    names.insert(countyName)
                                }
                            }
                        }
                        return resolve(names)
                        
                    } else {
                        return reject(SpitcastError.BadResponse)
                    }
            }
        }
    }
    
    static func get(allSpotsForCounties counties: Set<String>) -> Promise<[Int: SpotData]> {
        return Promise { resolve, reject in
            var countyRequests: [Promise<SpotDownloadResponse>] = []
            for county in counties {
                countyRequests.append(get(spotsInCounty: county))
            }
            
            when(fulfilled: countyRequests)
            .then { responses -> Void in
                var map: [Int: SpotData] = [:]
                for response in responses {
                    for spot in response.data {
                        map[spot.id] = spot
                    }
                }
                return resolve(map)
            }.recover { _ -> Void in
                return reject(SpitcastError.BadData)
            }
        }
    }
    
    private static func get(spotsInCounty county: String) -> Promise<SpotDownloadResponse> {
        return Promise { resolve, reject in
            request(spitcastURL + "/county/spots/" + format(stringForAPI: county), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseData { response in
                    guard let httpResponse = response.response, let responseData = response.result.value else {
                        print("Error in " + county)
                        return reject(SpitcastError.BadResponse)
                    }
                    
                    if httpResponse.statusCode == 200 {
                        let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: [])
                        guard let array = jsonData as? [Any] else {
                            print("Error in " + county)
                            return reject(SpitcastError.BadData)
                        }
                        
                        var spots: [SpotData] = []
                        for item in array {
                            if let spot = item as? [String: Any] {
                                if let id = spot["spot_id"] as? Int, let name = spot["spot_name"] as? String {
                                    spots.append(SpotData(id: id, name: name, county: county, location: nil, heights: nil, conditions: nil))
                                }
                            }
                        }
                        
                        return resolve(SpotDownloadResponse(data: spots))
                    } else {
                        print("Error in " + county)
                        return reject(SpitcastError.BadResponse)
                    }
            }
        }
    }
    
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
