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
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("will activate")
        refreshSpotsFromWatchConnectivity()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func refreshSpotsFromWatchConnectivity() {
        if var spots = FSWKDataManager.sharedManager.readSpotLibrarySelectionsFromDefaults() {
            if !spots.isEmpty {
            
                let currentHour = NSDate().hour()
                
                func sortByHeight(spot1: SpotData, spot2: SpotData) -> Bool {
                    if spot1.heights == nil || spot2.heights == nil {
                        return false
                    }
                    else if spot1.heights!.count != spot2.heights!.count {
                        return false
                    }
                    else {
                        return spot1.heights![currentHour] > spot2.heights![currentHour]
                    }
                }
                spots = spots.sort(sortByHeight)
                
                // intialize row types array with top spot
                var rowTypes: [String] = ["FSWKTopSpotRow"]
                
                // add a row type for every pair of default spots coming up
                let numberNotTop = spots.count - 1
                var numberRowsForNotTops = numberNotTop / 2
                if numberNotTop % 2 != 0 {
                    numberRowsForNotTops = numberRowsForNotTops + 1
                }
                
                if numberRowsForNotTops > 0 {
                    for _ in 0...numberRowsForNotTops - 1 {
                        rowTypes.append("FSWKDefaultSpotRow")
                    }
                }
                
                // set row types
                table.setRowTypes(rowTypes)
                print(rowTypes)
                
                // set first row
                if let row = table.rowControllerAtIndex(0) as? FSWKTopSpotRow {
                    let spot = spots[0]
                    row.composeRow(spot)
                }
                
                // if there are more, set other rows
                if spots.count > 1 {
                    
                    spots.removeFirst()
                    
                    for i in 1...numberRowsForNotTops {
                        
                        print(i)
                        
                        if let row = table.rowControllerAtIndex(i) as? FSWKDefaultSpotRow {

                            let firstSpotIndex = (2 * i) - 1
                            let secondSpotIndex = firstSpotIndex + 1
                            
                            var dataForFirstSpot: SpotData? = nil
                            var dataForSecondSpot: SpotData? = nil
                            
                            if firstSpotIndex - 1 < spots.count {
                                dataForFirstSpot = spots[firstSpotIndex - 1]
                            }
                            if secondSpotIndex - 1 < spots.count {
                                dataForSecondSpot = spots[secondSpotIndex - 1]
                            }
                            
                            row.composeRow(dataForFirstSpot, secondSpotData: dataForSecondSpot)
                        }
                    }
                    
                }

            }
        }
    }
}



//            for i in 0...table.numberOfRows - 1 {
//                if i == 0 {
//                    if let row = table.rowControllerAtIndex(i) as? FSWKTopSpotRow {
//                        let spot = spots[i]
//                        row.nameLabel.setText(spot.name)
//                        row.heightRow.setText("--ft")
//                        if let spotHeights = spot.heights {
//                            let currentHeight = Int(spotHeights[NSDate().hour()])
//                            row.heightRow.setText("\(currentHeight)ft")
//                        }
//                    }
//                } else {
//                    if let row = table.rowControllerAtIndex(i) as? FSWKDefaultSpotRow {
//                        let spot = spots[i]
//
//                    }
//                }
//
//

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

