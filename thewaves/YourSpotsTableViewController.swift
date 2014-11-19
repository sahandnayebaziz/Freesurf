//
//  YourSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class YourSpotsTableViewController: UITableViewController {
    @IBOutlet var yourSpotsTableView: UITableView!
    var yourSpotLibrary:SpotLibrary = SpotLibrary()
    var currentHour:Int = NSDate().hour()
    var usingUserDefaults:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yourSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "yourSpotsTableViewCell")
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
            usingUserDefaults = true
            self.yourSpotLibrary.initLibraryFromString(exportString)
            self.yourSpotsTableView.reloadData()
        }

        self.yourSpotsTableView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        // if there isn't internet, set a flag, while wait until we are connected to the internet, and as soon as we are break
        if !(isConnectedToNetwork()) {
            dispatch_to_background_queue {
                self.waitForConnection()
            }
        }
        
        // if no data has been loaded
        // TODO: make loading a dictionary non-destructive, and do it every time
        if yourSpotLibrary.spotDataDictionary.isEmpty || usingUserDefaults {
            if isConnectedToNetwork() {
                dispatch_to_background_queue {
                    self.yourSpotLibrary.getCounties()
                }
                usingUserDefaults = false;
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
                if yourSpotLibrary.next24Tides(spot) == nil {
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
    
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        var source:SearchForNewSpotsTableViewController = segue.sourceViewController as SearchForNewSpotsTableViewController
        source.searchField.resignFirstResponder()
        self.yourSpotLibrary = source.searchSpotLibrary
        self.tableView.reloadData()
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
        let cell:YourSpotsCell = yourSpotsTableView.dequeueReusableCellWithIdentifier("yourSpotsCell") as YourSpotsCell
        cell.backgroundColor = UIColor.clearColor()
        
        let libraryHeight = yourSpotLibrary.heightAtHour(rowID, hour: currentHour)
        let libraryTemp = yourSpotLibrary.waterTemp(rowID)
        let libraryTides = yourSpotLibrary.next24Tides(rowID)

        if libraryHeight != nil && libraryTemp != nil && libraryTides != nil {
            cell.setCellLabels(yourSpotLibrary.name(rowID), height: libraryHeight, temp: libraryTemp, tides: libraryTides)
        }
        else {
            cell.setCellLabels(yourSpotLibrary.name(rowID), height: nil, temp: nil, tides: nil)
            dispatch_to_main_queue {
                self.yourSpotsTableView.reloadData()
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 130.0
        }
        else {
            return 113.0
        }
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        var nav:UINavigationController = segue.destinationViewController as UINavigationController
        let destinationView:SearchForNewSpotsTableViewController = nav.topViewController as SearchForNewSpotsTableViewController
        destinationView.searchSpotLibrary = yourSpotLibrary
    }
}

