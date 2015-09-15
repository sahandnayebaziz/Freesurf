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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let spots = FSWKDataManager.sharedManager.readSpotLibrarySelectionsFromDefaults() {
            
            var rowTypes = ["FSWKTopSpotRow"]
            for _ in 1...spots.count - 1 {
                rowTypes.append("normalRow")
            }
            table.setRowTypes(rowTypes)
            
            for i in 0...table.numberOfRows - 1 {
                
                if i == 0 {
                    let row = table.rowControllerAtIndex(i) as? FSWKTopSpotRow
                    let topSpot = spots[i]
                    
                    row?.nameLabel.setText(topSpot.name)
                    row?.heightLabel.setText("9ft")
                }
                else {
                    let row = table.rowControllerAtIndex(i) as? FSWKSurfReportRow
                    row?.nameLabel.setText(spots[i].name)
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

}
