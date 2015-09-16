//
//  FSWKSurfReportInterfaceController.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import WatchKit
import Foundation

class FSWKSurfReportInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    var spotData: Set<FSWKSpotData> = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let spots = FSWKDataManager.sharedManager.readSpotLibrarySelectionsFromDefaults() {
            
            var rowTypes: [String] = []
            
            for index in 0...spots.count - 1 {
                print(index)
                if index == 0 {
                    rowTypes.append("FSWKTopSpotRow")
                } else if (index % 2 == 1) {
                    rowTypes.append("rowNameLeft")
                } else {
                    rowTypes.append("rowNameRight")
                }
            }
            
            table.setRowTypes(rowTypes)
            
            for i in 0...table.numberOfRows - 1 {
                if let row = table.rowControllerAtIndex(i) as? FSWKSpotRow {
                    let spot = spots[i]
                    row.nameLabel.setText(spot.name)
                    if let spotHeights = spot.heights {
                        let currentHeight = Int(spotHeights[NSDate().hour()])
                        row.heightRow.setText("\(currentHeight)ft")
                    }
                }
            }
        } else {
            // TODO: display error
        }
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
//    func didDownloadSpotData(data: FSWKSpotData) {
//        spotData.insert(data)
//        
//        if let spots = FSWKDataManager.sharedManager.readSpotLibrarySelectionsFromDefaults() {
//            for i in 0...spots.count - 1 {
//                if spots[i].id == data.id {
//                    if let row = table.rowControllerAtIndex(i) as? FSWKLeftNameRow {
//                        row.heightLabel.setText("\(data.height)ft")
//                    } else {
//                        if let row = table.rowControllerAtIndex(i) as? FSWKTopSpotRow {
//                            row.heightLabel.setText("\(data.height)ft")
//                        }
//                    }
//                }
//            }
//        }
//        
//        table.setRowTypes([])
//    }
    
}
