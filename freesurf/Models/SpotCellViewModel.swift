//
//  SpotCellViewModel.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 1/30/15.
//  Copyright (c) 2015 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import QuartzCore

class SpotCellViewModel {
    
    // MARK: - Properties -
    var name:String
    var height:String
    var tempAndSwell:String
    var colors:[CGColor]
    
    // MARK: - Initializer -
    init(name:String, height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?, requestsComplete:Bool) {
        
        self.name = name
        
        var gradientTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 0.4)
        var gradientBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 0.4)
        
        self.tempAndSwell = "--° --s --"
        self.height = "--ft"
        
        if requestsComplete {
            
            if let height = height {
                self.height = "\(height)ft"
                
                if height <= 2 {
                    gradientTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 1.0)
                    gradientBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 1.0)
                }
                else if height <= 4 {
                    gradientTop = UIColor(red: 95/255.0, green: 146/255.0, blue: 185/255.0, alpha: 1.0)
                    gradientBottom = UIColor(red: 77/255.0, green: 139/255.0, blue: 186/255.0, alpha: 1.0)
                }
                else {
                    gradientTop = UIColor(red: 120/255.0, green: 188/255.0, blue: 240/255.0, alpha: 1.0)
                    gradientBottom = UIColor(red: 97/255.0, green: 179/255.0, blue: 242/255.0, alpha: 1.0)
                }
            }
            else {
                self.height = " "
            }
            
            var tempText:String
            var swellText:String
            if let waterTemp = waterTemp { tempText = "\(waterTemp)° " }
            else { tempText = "" }
            if let swell = swell { swellText = "\(swell.period)s \(swell.direction)" }
            else { swellText = "" }
            
            if "\(tempText)\(swellText)" == "" {
                self.tempAndSwell = " "
            }
            else {
                self.tempAndSwell = "\(tempText)\(swellText)"
            }

        }
        
        colors = [gradientTop.cgColor, gradientBottom.cgColor]
        
        
    }
}
