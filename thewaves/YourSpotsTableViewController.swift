//
//  YourSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class YourSpotsTableViewController: UITableViewController {
    var yourSpotLibrary:SpotLibrary = SpotLibrary()
    @IBOutlet var yourSpotsTableView: UITableView!
    var currentHour:Int = NSDate().hour()
    
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        var source:SearchForNewSpotsTableViewController = segue.sourceViewController as SearchForNewSpotsTableViewController
        source.searchField.resignFirstResponder()
        self.yourSpotLibrary = source.searchSpotLibrary
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yourSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "yourSpotsTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        // if there isn't internet, set a flag, while wait until we are connected to the internet, and as soon as we are break
        if !(isConnectedToNetwork()) {
            dispatch_to_background_queue {
                self.waitForConnection()
            }
        }
        
        // if no data has been loaded
        if yourSpotLibrary.spotDataDictionary.isEmpty {
            if isConnectedToNetwork() {
                dispatch_to_background_queue {
                    self.yourSpotLibrary.getCounties()
                }
            }
        }
        
        // if anything has been selected
        if yourSpotLibrary.selectedSpotIDs.count > 0 {
            for spot in yourSpotLibrary.selectedSpotIDs {
                if yourSpotLibrary.heightAtHour(spot, hour: self.currentHour) == nil {
                    if isConnectedToNetwork() {
                        dispatch_to_background_queue {
                            self.yourSpotLibrary.getSpotSwell(spot)
                        }
                    }
                }
                if yourSpotLibrary.waterTemp(spot) == nil {
                    if isConnectedToNetwork() {
                        dispatch_to_background_queue {
                            self.yourSpotLibrary.getCountyWaterTemp(self.yourSpotLibrary.county(spot))
                        }
                    }
                }
                if yourSpotLibrary.currentTide(spot) == nil {
                    if isConnectedToNetwork() {
                        dispatch_to_background_queue {
                            self.yourSpotLibrary.getCountyTide(self.yourSpotLibrary.county(spot))
                        }
                    }
                }
            }
        }
        
        yourSpotsTableView.reloadData()
    }
    
    // falls here if we are waiting for reconnect
    func waitForConnection() {
        var connectionFlag:Bool = false
        while !(connectionFlag) {
            if isConnectedToNetwork() {
                connectionFlag = true
            }
        }
        self.viewWillAppear(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourSpotLibrary.selectedSpotIDs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = yourSpotLibrary.selectedSpotIDs[indexPath.row]
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "yourSpotsTableViewCell")
        cell.textLabel!.text = yourSpotLibrary.name(rowID)
        
        let height = yourSpotLibrary.heightAtHour(rowID, hour: currentHour)
        let temp = yourSpotLibrary.waterTemp(rowID)
        let tide = yourSpotLibrary.currentTide(rowID)
        
        if height != nil && temp != nil && tide != nil {
            cell.detailTextLabel!.text = "t:\(tide!) \(height!)ft \(temp!)°"
        }
        else {
            cell.detailTextLabel!.text = "--ft --°"
            dispatch_to_main_queue {
                self.yourSpotsTableView.reloadData()
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        yourSpotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool  {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            self.yourSpotsTableView.beginUpdates()
            yourSpotLibrary.selectedSpotIDs.removeAtIndex(indexPath.row)
            yourSpotsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            self.yourSpotsTableView.endUpdates()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        var nav:UINavigationController = segue.destinationViewController as UINavigationController
        let destinationView:SearchForNewSpotsTableViewController = nav.topViewController as SearchForNewSpotsTableViewController
        destinationView.searchSpotLibrary = yourSpotLibrary
    }
}

