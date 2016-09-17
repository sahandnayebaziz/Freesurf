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

    var heightLabel: UILabel? = nil
    var tempAndSwellLabel: UILabel? = nil
    var nameLabel: UILabel? = nil
    var gradient = CAGradientLayer()
    
    func set(forSpot spot: SpotData) {
        createSubviews()
        representedSpot = spot
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        gradient.colors = spot.gradientColorsForHeight
        gradient.frame = self.bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func createSubviews() {
        if heightLabel == nil {
            heightLabel = UILabel()
            heightLabel?.font = UIFont.systemFont(ofSize: 59, weight: UIFontWeightThin)
            heightLabel?.textColor = UIColor.white
            heightLabel?.textAlignment = .right
            addSubview(heightLabel!)
            heightLabel?.snp.makeConstraints { make in
                make.height.equalTo(60)
                make.right.equalTo(self).offset(-15)
                make.centerY.equalTo(self)
            }
        }
        
        if nameLabel == nil {
            nameLabel = UILabel()
            nameLabel?.font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightRegular)
            nameLabel?.textColor = UIColor.white
            nameLabel?.textAlignment = .left
            addSubview(nameLabel!)
            nameLabel!.snp.makeConstraints { make in
                make.bottom.equalTo(self).offset(-10)
                make.left.equalTo(16)
                make.right.equalTo(heightLabel!.snp.left)
                make.height.equalTo(33)
            }
        }
        
        if tempAndSwellLabel == nil {
            tempAndSwellLabel = UILabel()
            tempAndSwellLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
            tempAndSwellLabel?.textColor = UIColor.white
            addSubview(tempAndSwellLabel!)
            tempAndSwellLabel?.snp.makeConstraints { make in
                make.top.equalTo(13)
                make.left.equalTo(16)
                make.right.equalTo(heightLabel!.snp.left).offset(-10)
                make.height.equalTo(16)
            }
        }
        
        
    }
    
    func did(updateSpot spot: SpotData) {
        guard representedSpot != nil else {
            return
        }
        
        guard spot.id == representedSpot!.id else {
            return
        }
        
        self.heightLabel?.text = spot.heightString
        self.nameLabel?.text = spot.name
        gradient.colors = spot.gradientColorsForHeight
    }
    
    func did(updateCounty county: CountyData) {
        guard representedSpot != nil else {
            return
        }
        
        guard county.name == representedSpot!.county else {
            return
        }
        
        self.tempAndSwellLabel?.text = county.temperatureAndSwellSummary
    }
    
    func didLoadSavedSpots(spotsFound: Bool) {}
    func _devDidLoadAllSpots() {}
}
