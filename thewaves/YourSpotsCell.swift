//
//  YourSpotsCell.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 11/2/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import QuartzCore

class YourSpotsCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    let gradient:CAGradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellLabels(name: String, height: Int?, temp: Int?, tides: [Int]?) {
        nameLabel.text = name;
        var colorTop:CGColorRef;
        var colorBottom:CGColorRef;
        if height == nil || temp == nil || tides == nil {
            heightLabel.text = "--ft"
            tempLabel.text = "--°"
            colorTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 0.4).CGColor!
            colorBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 0.4).CGColor!
        }
        else {
            //decide color of cell
            if height <= 2 {
                colorTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 1.0).CGColor!
                colorBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 1.0).CGColor!
            }
            else if height <= 4 {
                colorTop = UIColor(red: 95/255.0, green: 146/255.0, blue: 185/255.0, alpha: 1.0).CGColor!
                colorBottom = UIColor(red: 77/255.0, green: 139/255.0, blue: 186/255.0, alpha: 1.0).CGColor!
            }
            else {
                colorTop = UIColor(red: 120/255.0, green: 188/255.0, blue: 240/255.0, alpha: 1.0).CGColor!
                colorBottom = UIColor(red: 97/255.0, green: 179/255.0, blue: 242/255.0, alpha: 1.0).CGColor!
            }
            
            // fill labels
            heightLabel.text = "\(height!)ft"
            tempLabel.text = "\(temp!)°   15s SW"
            
            var maxTide:Int = 0;
            var maxTideHoursFromNow:Int = 0;
            var minTide:Int = 999;
            var minTideHoursFromNow:Int = 999;
            
            for var index = 12; index >= 0; index-- {
                if (tides![index] >= maxTide) {
                    maxTide = tides![index]
                    maxTideHoursFromNow = index
                }
                if (tides![index] <= minTide) {
                    minTide = tides![index]
                    minTideHoursFromNow = index
                }
            }
            
            var highTideHeadline:String
            var lowTideHeadline:String
            if maxTideHoursFromNow <= 1 { highTideHeadline = "now" }
            else { highTideHeadline = "in \(maxTideHoursFromNow) hours" }
            if minTideHoursFromNow <= 1 { lowTideHeadline = "now" }
            else { lowTideHeadline = "in \(minTideHoursFromNow) hours" }
            
        }
        gradient.colors = [colorTop, colorBottom]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, atIndex: 0)
    }

}
