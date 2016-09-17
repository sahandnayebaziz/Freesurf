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

struct SpotHeightResponse {
    var id: Int
    var heights: [Float]?
    var conditions: [String]?
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
    
    static func get(heightsAndConditionsForSpot spotId: Int) -> Promise<SpotHeightResponse> {
        return Promise { resolve, reject in
            request(spitcastURL + "/spot/forecast/\(spotId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseData { response in
                    guard let httpResponse = response.response, let responseData = response.result.value else {
                        return reject(SpitcastError.BadResponse)
                    }
                    
                    if httpResponse.statusCode == 200 {
                        let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: [])
                        guard let array = jsonData as? [Any] else {
                            return reject(SpitcastError.BadData)
                        }
                        
                        var heights: [Float] = []
                        var conditions: [String] = []
                        for item in array {
                            if let spot = item as? [String: Any] {
                                if let height = spot["size_ft"] as? Float { heights.append(height) }
                                if let condition = spot["shape_full"] as? String { conditions.append(condition) }
                            }
                        }
                        
                        resolve(SpotHeightResponse(id: spotId, heights: heights.isEmpty ? nil : heights, conditions: conditions.isEmpty ? nil : conditions))
                    } else {
                        return reject(SpitcastError.BadResponse)
                    }
            }
        }
    }
}
