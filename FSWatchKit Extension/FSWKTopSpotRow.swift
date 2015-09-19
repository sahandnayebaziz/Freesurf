//
//  FSWKTopSpotRow.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import WatchKit

class FSWKTopSpotRow: NSObject {
    
    var parentTable: FSWKSurfReportInterfaceController!
    
    var representedData: SpotData! {
        didSet {
            self.composeRow(representedData)
        }
    }
    
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var heightLabel: WKInterfaceLabel!
    
    private func composeRow(data: SpotData) {
        let currentHour = NSDate().hour()
        
        nameLabel.setText(data.name)
        if let heights = data.heights {
            if heights.count > 1 {
                heightLabel.setText("\(Int(heights[currentHour]))ft")
            } else {
                heightLabel.setText("\(Int(heights[0]))ft")
            }
        } else {
            heightLabel.setText("--ft")
            FSWKDataManager.sharedManager.downloadData(data.id).then { heightReceived -> Void in
                self.heightLabel.setText("\(heightReceived)ft")
                let newData = SpotData(serialized: data.serialized)
                newData.heights = [Float(heightReceived)]
                self.parentTable.updateDataForSpotInBuffer(data, newData: newData)
            }
        }
    }

}
