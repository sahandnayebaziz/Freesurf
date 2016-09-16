//
//  SpotCell.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 1/30/15.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import QuartzCore

// a SpotCell displays a preview of spot information on the main view
class SpotCell: UITableViewCell {

    // MARK: - Properties -
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var tempAndSwellLabel: UILabel!
    var gradient:CAGradientLayer = CAGradientLayer()

    // MARK: - Initializers -
    convenience init(model:SpotCellViewModel) {
        self.init()
        setValues(model)
    }
    
    // MARK: - Methods -
    func setValues(_ model: SpotCellViewModel) {
        self.nameLabel.text = model.name
        self.heightLabel.text = model.height
        self.tempAndSwellLabel.text = model.tempAndSwell
        self.gradient.colors = model.colors
        
        self.gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}
