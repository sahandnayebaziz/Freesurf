//
//  YourSpotsCell.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 11/2/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import QuartzCore

// YourSpotsCell is the class of every cell added to the table view of the apps main view, an instance of YourSpotsTableViewController.
// :: Each YourSpotsCell displays the following data for a spot: name, current swell height, current water temperature, current direction and period of most significant swell affecting the spot
class YourSpotsCell: UITableViewCell {

    // nameLabel displays the name of the spot. 
    // :: the cell is never displayed without the name of the spot entered in this label
    @IBOutlet weak var nameLabel: UILabel!
    
    // heightLabel displays the current swell height for this spot.
    // :: this label displays a placeholder value to indicate that this data hasn't been stored yet
    @IBOutlet weak var heightLabel: UILabel!
    
    // tempLabel displays the temperature, swell period, and swell direction for this spot.
    // :: this label displays a placeholder value to indicate that this data hasn't been stored yet
    @IBOutlet weak var tempLabel: UILabel!
    
    // cells are instantiated with a CAGradientLayer that will be set to a gradient of blues based on the size of their current swell height
    let gradient:CAGradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // setCellLabels updates the labels of this cell with placeholder values if data for this spot hasn't been stored, or real data
    // if data for this spot has been stored. setCellLabels also sets the colors of the cells background. TODO: separate gradient code from this method
    func setCellLabels(name:String, values:(height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?)?) {
        
        nameLabel.text = name
        heightLabel.text = "--ft"
        tempLabel.text = "--° --s --"
        var colorTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 0.4).CGColor!
        var colorBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 0.4).CGColor!
        
        if values != nil {
            var tempText = ""
            var swellText = ""
            
            if values!.height != nil {
                heightLabel.text = "\(values!.height!)ft"
                if values!.height! <= 2 {
                    colorTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 1.0).CGColor!
                    colorBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 1.0).CGColor!
                }
                else if values!.height! <= 4 {
                    colorTop = UIColor(red: 95/255.0, green: 146/255.0, blue: 185/255.0, alpha: 1.0).CGColor!
                    colorBottom = UIColor(red: 77/255.0, green: 139/255.0, blue: 186/255.0, alpha: 1.0).CGColor!
                }
                else {
                    colorTop = UIColor(red: 120/255.0, green: 188/255.0, blue: 240/255.0, alpha: 1.0).CGColor!
                    colorBottom = UIColor(red: 97/255.0, green: 179/255.0, blue: 242/255.0, alpha: 1.0).CGColor!
                }
            }
            if values!.swell != nil {
                swellText = "\(values!.swell!.period)s \(values!.swell!.direction)"
            }
            if values!.waterTemp != nil {
                tempText = "\(values!.waterTemp!)° "
            }
            tempLabel.text = "\(tempText)\(swellText)"
        }

        // add the decided colors to the gradient object
        gradient.colors = [colorTop, colorBottom]
        
        // set the size of the gradient layer to be the entire display size of the cell
        gradient.frame = self.bounds
        
        // add the gradient layer beneath the layer with labels
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
}
