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
    var conditions: String?
    
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
}

struct Swell: Equatable, Comparable {
    var height: Int
    var period: Int
    var direction: String
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
    var waterTemperature: Int?
    var tides: [Float]?
    var swells: [Swell]?
    var wind: Wind?
    
    var significantSwell: Swell? {
        guard let allSwells = self.swells else {
            return nil
        }
        return allSwells.max()
    }
    
    var temperatureAndSwellSummary: String {
        let temperature = waterTemperature != nil ? "\(waterTemperature!)°" : ""
        let swell = significantSwell != nil ? "\(significantSwell!.period)s \(significantSwell!.direction)" : ""
        return "\(temperature) \(swell)"
    }
}
