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
    
    func setCellLabels(name: String, height: Int?, temp: Int?, periods: [Int]?, heights: [Int]?, directions: [String]?) {
        nameLabel.text = name;
        var colorTop:CGColorRef;
        var colorBottom:CGColorRef;
        if height == nil || temp == nil || periods == nil || heights == nil || directions == nil {
            heightLabel.text = "--ft"
            tempLabel.text = "--°   --s --"
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
            
            // figure most significant swell
            var indexOfMostSignifcantSwellInSwellData:Int = 0
            var heightOfMostSignificantSwellInSwellData:Int = -1
            
            for (var possibleMaxHeightIndex:Int = 0; possibleMaxHeightIndex < heights!.count; possibleMaxHeightIndex++) {
                
                if heights![possibleMaxHeightIndex] > heightOfMostSignificantSwellInSwellData {
                    heightOfMostSignificantSwellInSwellData = heights![possibleMaxHeightIndex]
                    indexOfMostSignifcantSwellInSwellData = possibleMaxHeightIndex
                }
            }
            
            let periodOfMostSignificantSwellInSwellData:Int = periods![indexOfMostSignifcantSwellInSwellData]
            let directionOfMostSignificantSwellInSwellData:String = directions![indexOfMostSignifcantSwellInSwellData]
            
            
            
            // fill labels
            heightLabel.text = "\(height!)ft"
            tempLabel.text = "\(temp!)°   \(periodOfMostSignificantSwellInSwellData)s \(directionOfMostSignificantSwellInSwellData)"
        }
        gradient.colors = [colorTop, colorBottom]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, atIndex: 0)
    }

}
