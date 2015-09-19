//
//  FSWKSurfReportInterfaceController.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import WatchKit
import Foundation
import PromiseKit

class FSWKSurfReportInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    var spotBuffer: Set<SpotData> = Set<SpotData>()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        if let spots = FSWKDataManager.sharedManager.readSpotLibrarySelectionsFromDefaults() {
            spotBuffer = []
            
            for spot in spots {
                spotBuffer.insert(spot)
            }
            
            createRowsFromSpotData(spotBuffer)
        } else {
            displayEmptyMessage()
        }
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func createRowsFromSpotData(data: Set<SpotData>) {
        if !data.isEmpty {
            
            let currentHour = NSDate().hour()
            
            func sortByHeight(spot1: SpotData, spot2: SpotData) -> Bool {
                if spot1.heights == nil || spot2.heights == nil {
                    return false
                }
                else if spot1.heights!.count != spot2.heights!.count {
                    return false
                }
                else if spot1.heights!.count > 1 {
                    return spot1.heights![currentHour] > spot2.heights![currentHour]
                }
                else {
                    return spot1.heights![0] > spot2.heights![0]
                }
            }
            
            var spots = Array(data).sort(sortByHeight)
            
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
                row.representedData = spot
                row.parentTable = self
            }
            
            // if there are more, set other rows
            if spots.count > 1 {
                
                spots.removeFirst()
                
                for i in 1...numberRowsForNotTops {
                    
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
                        
                        row.representedData = ["spot1": dataForFirstSpot, "spot2": dataForSecondSpot]
                        row.parentTable = self
                    }
                }
                
            }
            
        }
    }
    
    func updateDataForSpotInBuffer(oldData: SpotData, newData: SpotData) {
        spotBuffer.remove(oldData)
        spotBuffer.insert(newData)
        createRowsFromSpotData(spotBuffer)
    }
    
    func displayEmptyMessage() {
        table.setRowTypes(["emptyMessage"])
    }
}
