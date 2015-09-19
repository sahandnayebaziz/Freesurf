//
//  FSWKTopSpotRow.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import WatchKit

class FSWKTopSpotRow: NSObject {

    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var heightLabel: WKInterfaceLabel!
    
    func composeRow(data: SpotData) {
        let currentHour = NSDate().hour()
        
        nameLabel.setText(data.name)
        if let heights = data.heights {
            heightLabel.setText("\(Int(heights[currentHour]))ft")
        } else {
            heightLabel.setText("--ft")
        }
    }

}
