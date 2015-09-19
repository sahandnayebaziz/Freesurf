//
//  FSWKDefaultSpotRow.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/18/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import WatchKit
import PromiseKit
import Alamofire

class FSWKDefaultSpotRow: NSObject {
    
    var parentTable: FSWKSurfReportInterfaceController!
    
    var representedData: [String:SpotData?] = [:] {
        didSet {
            self.composeRow(representedData["spot1"]!, secondSpotData: representedData["spot2"]!)
        }
    }

    @IBOutlet var firstSpotHeight: WKInterfaceLabel!
    @IBOutlet var firstSpotName: WKInterfaceLabel!
    
    @IBOutlet var secondSpotHeight: WKInterfaceLabel!
    @IBOutlet var secondSpotName: WKInterfaceLabel!
    
    private func composeRow(firstSpotData: SpotData?, secondSpotData: SpotData?) {
        
        let currentHour = NSDate().hour()
        
        for (data, name, height) in [(firstSpotData, firstSpotName, firstSpotHeight), (secondSpotData, secondSpotName, secondSpotHeight)] {
            if let data = data {
                name.setText(data.name)
                if let heights = data.heights {
                    if heights.count > 1 {
                        height.setText("\(Int(heights[currentHour]))ft")
                    } else {
                        height.setText("\(Int(heights[0]))ft")
                    }
                    
                } else {
                    height.setText("--ft")
                    FSWKDataManager.sharedManager.downloadData(data.id).then { heightReceived -> Void in
                        height.setText("\(heightReceived)ft")
                        let newData = SpotData(serialized: data.serialized)
                        newData.heights = [Float(heightReceived)]
                        self.parentTable.updateDataForSpotInBuffer(data, newData: newData)
                    }
                }
            }
            else {
                name.setHidden(true)
                height.setHidden(true)
            }
        }
    }
    
}
