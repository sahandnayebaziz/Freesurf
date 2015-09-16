//
//  SpotData.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import CoreLocation

class SpotData: Equatable, CustomStringConvertible {
    var name:String
    var county:String
    var location:CLLocation?
    var heights:[Float]?
    var conditions:String?
    
    init(name: String, county: String, location: CLLocation?, heights: [Float]?, conditions: String?) {
        self.name = name
        self.county = county
        self.location = location
        self.heights = heights
        self.conditions = conditions
    }
    
    var description: String {
        return "\(name) \(county) \(location) \(conditions)"
    }
    
    var serialized: NSData {
        var dict: [String:AnyObject] = [:]
        
        dict["name"] = name
        dict["county"] = county
        
        if let location = location {
            dict["location"] = location
        }
        if let heights = heights {
            dict["heights"] = heights
        }
        if let conditions = conditions {
            dict["conditions"] = conditions
        }
        
        return NSKeyedArchiver.archivedDataWithRootObject(dict)
    }
    
    init(serialized: NSData) {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(serialized) as! [String: AnyObject]
        
        if let name = dict["name"] as? String {
            self.name = name
        }
        else {
            self.name = "error"
        }
        
        if let county = dict["county"] as? String {
            self.county = county
        }
        else {
            self.county = "error"
        }
        
        if let location = dict["location"] as? CLLocation? {
            self.location = location
        } else {
          self.location = nil
        }
        
        if let heights = dict["heights"] as? [Float]? {
            self.heights = heights
        } else {
            self.heights = nil
        }
        
        if let conditions = dict["conditions"] as? String? {
            self.conditions = conditions
        } else {
            self.conditions = nil
        }
        
    }
}

func ==(lhs: SpotData, rhs: SpotData) -> Bool {
    let namesEqual = lhs.name == rhs.name
    let countiesEqual = lhs.county == rhs.county
    let conditionsEqual = lhs.conditions == rhs.conditions
    
    let locationsEqual: Bool
    if (lhs.location == nil && rhs.location != nil) || (lhs.location != nil && rhs.location == nil) {
        locationsEqual = false
    } else if lhs.location == nil && rhs.location == nil  {
        locationsEqual = true
    } else {
        locationsEqual = lhs.location!.distanceFromLocation(rhs.location!) == 0
    }
    
    let heightsEqual: Bool
    if (lhs.heights == nil && rhs.heights != nil) || (lhs.heights != nil && rhs.heights == nil) {
        heightsEqual = false
    } else if lhs.heights == nil && rhs.heights == nil  {
        heightsEqual = true
    } else {
        heightsEqual = lhs.heights! == rhs.heights!
    }
    
    return namesEqual && countiesEqual && locationsEqual && conditionsEqual && heightsEqual
}