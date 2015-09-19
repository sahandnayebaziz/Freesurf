//
//  FSWKDefaultSpotRow.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/18/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import WatchKit

class FSWKDefaultSpotRow: NSObject {

    @IBOutlet var firstSpotHeight: WKInterfaceLabel!
    @IBOutlet var firstSpotName: WKInterfaceLabel!
    
    @IBOutlet var secondSpotHeight: WKInterfaceLabel!
    @IBOutlet var secondSpotName: WKInterfaceLabel!
    
    func composeRow(firstSpotData: SpotData?, secondSpotData: SpotData?) {
        
        let currentHour = NSDate().hour()
        
        for (data, name, height) in [(firstSpotData, firstSpotName, firstSpotHeight), (secondSpotData, secondSpotName, secondSpotHeight)] {
            if let data = data {
                name.setText(data.name)
                if let heights = data.heights {
                    height.setText("\(Int(heights[currentHour]))ft")
                } else {
                    height.setText("--ft")
                }
            }
            else {
                name.setHidden(true)
                height.setHidden(true)
            }
        }
    }
}
