////
////  DetailViewModel.swift
////  Freesurf
////
////  Created by Sahand Nayebaziz on 2/1/15.
////  Copyright (c) 2015 Sahand Nayebaziz. All rights reserved.
////
//
//import UIKit
//
//class DetailViewModel {
//    
//    // MARK: - Properties -
//    var name:String
//    var height:String
//    var temp:String
//    
//    var swellDirection:String
//    var swellPeriod:String
//    var condition:String
//    var wind:String
//    
//    var tides:[CGFloat]
//    var heights:[CGFloat]
//    
//    // MARK: - Initializers -
//    init(values:(name:String, height:Int?, waterTemp:Int?, swell:Swell?, condition:String?, wind:Wind?, tides:[Float]?, heights:[Float]?)) {
//
//
//        
//        if let wind = values.wind {
//            self.wind = "\(wind.direction) @ \(wind.speed) MPH"
//        }
//        else {
//            self.wind = " "
//        }
//        
//        var tidesAsCGFloats:[CGFloat] = []
//        if let tides = values.tides {
//            for tide in tides { tidesAsCGFloats.append(CGFloat(tide)) }
//            self.tides = tidesAsCGFloats
//        }
//        else {
//            for _ in 0...24 { tidesAsCGFloats.append(CGFloat(0)) }
//            self.tides = tidesAsCGFloats
//        }
//        
//        var heightsAsCGFloats:[CGFloat] = []
//        if let heights = values.heights {
//            for height in heights { heightsAsCGFloats.append(CGFloat(Int(height))) }
//            self.heights = heightsAsCGFloats
//        }
//        else {
//            for _ in 0...24 { heightsAsCGFloats.append(CGFloat(0)) }
//            self.heights = heightsAsCGFloats
//        }
//        
//    }
//    
//}
