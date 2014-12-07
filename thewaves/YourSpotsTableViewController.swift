//
//  YourSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class YourSpotsTableViewController: UITableViewController {
    @IBOutlet var yourSpotsTableView: UITableView! // the main table view
    @IBOutlet weak var footer: UIView! // the view at the bottom
    var spotLibrary:SpotLibrary = SpotLibrary() // this object is created here, and then passed back and forth between this controller and the search controller
    var currentHour:Int = NSDate().hour() // this is passed to SpotLibrary methods to populate the cells
    var usingUserDefaults:Bool = false // this flag is set when we use NSUserDefaults to load the user's selected spots. Tells controller to download the remaining spots

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // registers our custom cell
        self.yourSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "yourSpotsTableViewCell")
        
        // loads the a serialized string that contains the names and IDs of spots the user had added the last time the app was used
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
            usingUserDefaults = true // set flag to true, so we know to download the remaining spots
            self.spotLibrary.initLibraryFromString(exportString) // calls the deserialize function on the string saved in NSUserDefaults
            self.yourSpotsTableView.reloadData() // reloads the data
        }

        // set the background color of the view
        self.yourSpotsTableView.backgroundColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1.0)
    }

    override func viewWillAppear(animated: Bool) {
        // if there isn't internet, set a flag, while wait until we are connected to the internet, and as soon as we are break
        if !(isConnectedToNetwork()) {
            dispatch_to_background_queue { // dispatch to background queue takes a function and pushes it onto a background thread
                self.waitForConnection()
            }
        }
        
        // checks to see if information like swell height and tides has been downloaded for spots that have been selected
        // this is where this information is downloaded and the spotLibrary dictionary is filled
        downloadMissingSpotInfo()
        
        // sets the footer view of the table view, sets the height of the view to be 100
        footer.frame = CGRect(x: footer.frame.minX, y: footer.frame.minY, width: footer.frame.maxX, height: 100)
        yourSpotsTableView.tableFooterView = footer
    }
    
    
    
    // this is function is called when we return from another view with the "unwindToList" segue
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        if segue.identifier != nil {
            if segue.identifier! == "unwindFromSearchCell" || segue.identifier! == "unwindFromSearchCancelButton" {
                // identify the view we're coming from as the searchForNewSpots view
                var source:SearchForNewSpotsTableViewController = segue.sourceViewController as SearchForNewSpotsTableViewController
                
                // replace this controller's SpotLibrary object with the newer one coming back from the view
                self.spotLibrary = source.spotLibrary
                
                // dismiss the keyboard
                source.searchField.resignFirstResponder()
                source.dismissViewControllerAnimated(true, completion: nil)
                
                // reload this table view's data with the new SpotLibrary object
                self.tableView.reloadData()
                self.downloadMissingSpotInfo()
            }
            else if segue.identifier! == "unwindFromSpotDetail" {
                
            }
        }
        else {
            NSLog("Error. Returned to main view with an unnamed segue.")
        }
    }
    
    // this is a hacky solution to wait for a connection, but it works.
    func waitForConnection() {
        // set a flag for us to loop on
        var connectionFlag:Bool = false
        
        // keep checking for an internet connection until we get one, then exit and call viewWillApear again
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
        return 1 // only one section here
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotLibrary.selectedSpotIDs.count // the number of rows comes from the count of array selectedSpotIDs in this controller's current SpotLibrary object
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // this is the ID of the cell at this indexPath
        let rowID = spotLibrary.selectedSpotIDs[indexPath.row]
        
        // get values necessary for a cell. May be nil.
        let libraryHeight:Int? = spotLibrary.heightAtHour(rowID, hour: currentHour)
        let libraryTemp:Int? = spotLibrary.waterTemp(rowID)
        let libraryPeriods:[Int]? = spotLibrary.periodsForNext24Hours(rowID, hour: 0)
        let libraryHeights:[Int]? = spotLibrary.heightsForNext24Hours(rowID, hour: 0)
        let libraryDirections:[String]? = spotLibrary.directionsForNext24Hours(rowID, hour: 0)
        
        // create and return the cell
        let cell:YourSpotsCell = yourSpotsTableView.dequeueReusableCellWithIdentifier("yourSpotsCell", forIndexPath: indexPath) as YourSpotsCell
        cell.backgroundColor = UIColor.clearColor() // the cell starts with a clear background before getting a gradient color.
        if libraryHeight != nil && libraryTemp != nil && libraryPeriods != nil && libraryHeights != nil && libraryDirections != nil { // if spot values are all here, send to the cell
            cell.setCellLabels(spotLibrary.name(rowID), height: libraryHeight, temp: libraryTemp, periods: libraryPeriods, heights: libraryHeights, directions: libraryDirections)
        }
        else { // if any of the values are still nil, keep the cell blank
            cell.setCellLabels(spotLibrary.name(rowID), height: nil, temp: nil, periods: nil, heights: nil, directions: nil)
            dispatch_to_main_queue { // check again to see if the values are here yet at the end of the main queue
                self.yourSpotsTableView.reloadData()
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // give the first cell a taller height to make up for the status bar
        if indexPath.row == 0 {
            return 97.0
        }
        else { // give every other cell a height that is slightly smaller
            return 76.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        // selecting a cell is currently disabled. When you select it, it just gets disabled real quick.
        yourSpotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool  {
        return self.spotLibrary.selectedSpotIDs.count > 1
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // beginUpdates and endUpdates allow us to animate cells being deleted
            self.yourSpotsTableView.beginUpdates()
            spotLibrary.selectedSpotIDs.removeAtIndex(indexPath.row) // delete the entry in selectedSpotIDs in the SpotLibrary object
            yourSpotsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            self.yourSpotsTableView.endUpdates()
        }
    }
    
    // set the statusBar to be light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // this function is called right before we segue to another controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier != nil {
            if segue.identifier! == "openSearchForSpots" {
                // identify destination controller
                let nav:UINavigationController = segue.destinationViewController as UINavigationController
                let destinationView:SearchForNewSpotsTableViewController = nav.topViewController as SearchForNewSpotsTableViewController
                
                // pass our SpotLibrary object to the destination view controller for a new spot to be added.
                // This will be passed back when we leave that view, whether changed or unchanged
                destinationView.spotLibrary = self.spotLibrary
            }
            if segue.identifier! == "openSpotDetail" {
                let nav:UINavigationController = segue.destinationViewController as UINavigationController
                let destinationView:SpotDetailViewController = nav.topViewController as SpotDetailViewController
                
                let indexPath:NSIndexPath = yourSpotsTableView.indexPathForSelectedRow()!
                let rowID = spotLibrary.selectedSpotIDs[indexPath.row]
                
                destinationView.spotLibrary = self.spotLibrary
                destinationView.selectedSpotID = rowID
            }
        }
        else {
            NSLog("segues should all be named")
        }
    }
    
    func downloadMissingSpotInfo() {
        // if no data has been loaded
        if spotLibrary.spotDataDictionary.isEmpty || usingUserDefaults {
            if isConnectedToNetwork() {
                dispatch_to_background_queue {
                    self.spotLibrary.getCounties()
                }
                usingUserDefaults = false; // return this flag to false, so this getCounties call doesn't trip every time this view appears
            }
        }
        
        // dispatch calls for the swell, temp, and tide info for any selected spots
        if spotLibrary.selectedSpotIDs.count > 0 { // if any spots have been selected
            for spot in spotLibrary.selectedSpotIDs {
                if isConnectedToNetwork() {
                    
                    if spotLibrary.heightAtHour(spot, hour: self.currentHour) == nil { // call getter, if nil dispatch JSON download
                        dispatch_to_background_queue {
                            self.spotLibrary.getSpotSwell(spot)
                        }
                    }
                    
                    if spotLibrary.waterTemp(spot) == nil { // call getter, if nil dispatch JSON download
                        dispatch_to_background_queue {
                            self.spotLibrary.getCountyWaterTemp(self.spotLibrary.county(spot))
                        }
                    }
                    
                    if spotLibrary.next24Tides(spot) == nil { // call getter, if nil dispatch JSON download
                        dispatch_to_background_queue {
                            self.spotLibrary.getCountyTide(self.spotLibrary.county(spot))
                        }
                    }
                    
                    if spotLibrary.periodsForNext24Hours(spot, hour: self.currentHour) == nil {
                        dispatch_to_background_queue {
                            self.spotLibrary.getCountySwell(self.spotLibrary.county(spot))
                        }
                    }
                }
            }
        }
        
        yourSpotsTableView.reloadData() // reload the data in the table
    }
}

