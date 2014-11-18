//
//  YourSpotsCell.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 11/2/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class YourSpotsCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellLabels(name: String, height: Int?, temp: Int?) {
        nameLabel.text = name;
        if height == nil || temp == nil {
            heightLabel.text = "--ft"
            tempLabel.text = "--°"
        }
        else {
            heightLabel.text = "\(height!)ft"
            tempLabel.text = "\(temp!)°"
        }
    }

}
