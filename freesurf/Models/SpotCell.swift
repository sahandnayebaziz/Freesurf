//
//  SpotCell.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 1/30/15.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import QuartzCore



class SpotCell: UITableViewCell, SpotDataDelegate {
    
    var representedSpot: SpotData? = nil

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var tempAndSwellLabel: UILabel!
    var gradient:CAGradientLayer = CAGradientLayer()
    
    func set(forSpot spot: SpotData) {
        representedSpot = spot
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        gradient.colors = spot.gradientColorsForHeight
        gradient.frame = self.bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    func did(updateSpot spot: SpotData) {
        guard representedSpot != nil else {
            return
        }
        
        guard spot.id == representedSpot!.id else {
            return
        }
        
        self.heightLabel.text = spot.heightString
        self.nameLabel.text = spot.name
        gradient.colors = spot.gradientColorsForHeight
    }
    
    func did(updateCounty county: CountyData) {
        guard representedSpot != nil else {
            return
        }
        
        guard county.name == representedSpot!.county else {
            return
        }
    }
    
    func didUpdate(forSpot spot: SpotData, county: CountyData) {
        
        self.tempAndSwellLabel.text = county.temperatureAndSwellSummary
        
    }
    
    func didLoadSavedSpots(spotsFound: Bool) {}
    func _devDidLoadAllSpots() {}
}
