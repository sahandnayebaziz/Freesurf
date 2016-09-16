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

struct Spitcast {
    private static let spitcastURL = "http://api.spitcast.com/api"
    
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
    
    
    
}
