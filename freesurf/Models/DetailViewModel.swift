//
//  DetailViewModel.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 2/1/15.
//  Copyright (c) 2015 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class DetailViewModel {
    
    // MARK: - Properties -
    var name:String
    var height:String
    var temp:String
    
    
    var swellDirection:String
    var swellPeriod:String
    var condition:String
    var wind:String
    
    var tides:[CGFloat]
    var heights:[CGFloat]
    
    // MARK: - Initializers -
    init(values:(name:String, height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?, condition:String?, wind:(speedInMPH:Int, direction:String)?, tides:[Float]?, heights:[Float]?)) {
        
        self.name = values.name
        
        if let height = values.height { self.height = "\(height)-\(height + 1)ft" }
        else { self.height = " " }
        
        if let temp = values.waterTemp { self.temp = "\(temp)°" }
        else { self.temp = " " }
        
        if let swell = values.swell {
            self.swellDirection = swell.direction
            self.swellPeriod = "\(swell.period) SEC"
        }
        else {
            self.swellDirection = " "
            self.swellPeriod = " "
        }
        
        if let condition = values.condition {
            self.condition = condition.uppercaseString
        }
        else {
            self.condition = " "
        }
        
        if let wind = values.wind {
            self.wind = "\(wind.direction) @ \(wind.speedInMPH) MPH"
        }
        else {
            self.wind = " "
        }
        
        var tidesAsCGFloats:[CGFloat] = []
        if let tides = values.tides {
            for tide in tides { tidesAsCGFloats.append(CGFloat(tide)) }
            self.tides = tidesAsCGFloats
        }
        else {
            for _ in 0...24 { tidesAsCGFloats.append(CGFloat(0)) }
            self.tides = tidesAsCGFloats
        }
        
        var heightsAsCGFloats:[CGFloat] = []
        if let heights = values.heights {
            for height in heights { heightsAsCGFloats.append(CGFloat(Int(height))) }
            self.heights = heightsAsCGFloats
        }
        else {
            for _ in 0...24 { heightsAsCGFloats.append(CGFloat(0)) }
            self.heights = heightsAsCGFloats
        }
        
    }
    
}