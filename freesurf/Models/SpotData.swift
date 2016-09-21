//
//  Value types .swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/16/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct SpotData {
    var id: Int
    var name: String
    var county: String
    var location: CLLocation?
    var heights: [Float]?
    var conditions: [String]?
    
    var gradientColorsForHeight: [CGColor] {
        let topColor: UIColor
        let bottomColor: UIColor
        
        guard let allHeights = heights else {
            topColor = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 0.4)
            bottomColor = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 0.4)
            return [topColor.cgColor, bottomColor.cgColor]
        }
        
        let height = allHeights[Date().hour()]
        
        if height <= 2 {
            topColor = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 1.0)
            bottomColor = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 1.0)
        }
        else if height <= 4 {
            topColor = UIColor(red: 95/255.0, green: 146/255.0, blue: 185/255.0, alpha: 1.0)
            bottomColor = UIColor(red: 77/255.0, green: 139/255.0, blue: 186/255.0, alpha: 1.0)
        }
        else {
            topColor = UIColor(red: 120/255.0, green: 188/255.0, blue: 240/255.0, alpha: 1.0)
            bottomColor = UIColor(red: 97/255.0, green: 179/255.0, blue: 242/255.0, alpha: 1.0)
        }
        
        return [topColor.cgColor, bottomColor.cgColor]
    }
    
    var heightString: String {
        guard let heights = heights else {
            return "--ft"
        }
        
        let currentHour = Date().hour()
        guard heights.count >= currentHour else {
            NSLog("Incomplete heights error")
            return "--ft"
        }
        
        return "\(Int(heights[currentHour]))ft"
    }
    
    var heightRangeString: String {
        guard let heights = heights else {
            return "--ft"
        }
        
        let currentHour = Date().hour()
        guard heights.count >= currentHour else {
            NSLog("Incomplete heights error")
            return "--ft"
        }
        
        let height = Int(heights[currentHour])
        return "\(height)-\(height + 1)ft"
    }
    
    var conditionString: String {
        guard let conditions = conditions else {
            return ""
        }
        
        let currentHour = Date().hour()
        guard conditions.count >= currentHour else {
            NSLog("Incomplete swells error")
            return ""
        }
        
        return conditions[currentHour].uppercased()
    }
}

struct Swell: Equatable, Comparable {
    var height: Int
    var period: Int
    var direction: String
    
    static func inFeet(heightMeters: Float) -> Int { return Int(heightMeters * 3.2) }
    
    static func toString(degrees: Int) -> String {
        let listOfDirections:[String] = ["N", "NNW", "NW", "WNW", "W", "WSW", "SW", "SSW", "S", "SSE", "SE", "ESE", "E", "ENE", "NE", "NNE", "N"]
        return listOfDirections[((degrees) + (360/16)/2) % 360 / (360/16)]
    }
}

func ==(lhs: Swell, rhs: Swell) -> Bool {
    return lhs.height == rhs.height && lhs.period == rhs.period && lhs.direction == rhs.direction
}

func < (lhs: Swell, rhs: Swell) -> Bool {
    return lhs.height < rhs.height
}

struct Wind {
    var speed: Int
    var direction: String
}

struct CountyData {
    var name: String
    var waterTemperature: Int?
    var tides: [Float]?
    var swells: [[Swell]]?
    var wind: Wind?
    
    var significantSwell: Swell? {
        guard let allSwells = self.swells else {
            return nil
        }
        
        let currentHour = Date().hour()
        guard allSwells.count >= currentHour else {
            NSLog("Incomplete swells error")
            return nil
        }
        
        return allSwells[currentHour].max()
    }
    
    var temperatureAndSwellSummary: String {
        let temperature = waterTemperature != nil ? "\(waterTemperature!)° " : ""
        let swell = significantSwell != nil ? "\(significantSwell!.period)s \(significantSwell!.direction)" : ""
        return "\(temperature)\(swell)"
    }
    
    var waterTemperatureString: String {
        return waterTemperature != nil ? "\(waterTemperature!)°" : ""
    }
    
    var periodString: String {
        guard let period = significantSwell?.period else {
            return ""
        }
        
        return "\(period) SEC"
    }
    
    var windString: String {
        guard let wind = wind else {
            return ""
        }
        
        return "\(wind.direction) @ \(wind.speed) MPH"
    }
}
