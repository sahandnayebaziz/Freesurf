//
//  YourSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import Alamofire

// YourSpotsTableViewController controls the intial view for this app.
// :: the contained table view displays cells as instances of the class YourSpotsCell.
// :: this view controller initializes the SpotLibrary object that will be used throughout the app's lifecycle. This SpotLibrary object is initialized in viewDidLoad() from data saved in
//    NSUserDefaults if this is not the user's first session.
// :: once this controller contains a SpotLibrary object with spot ids saved in its selectedSpotIDs array, it will call SpotLibrary methods on a separate thread to populate
//    the SpotLibrary object with data relevant to the selected spots.
class YourSpotsTableViewController: UITableViewController, LPRTableViewDelegate {
    
    // yourSpotsTableView is populated with YourSpotsCells for each spot the user has selected in the SearchForNewSpots view
    @IBOutlet var yourSpotsTableView:LPRTableView!
    
    // this view contains the onboarding instructions that are only displayed
    // until the user has added their first spot to their list of saved spots
    @IBOutlet weak var header: UIView!
    
    // this view contains the "add spot" button that moves the user to the SearchForNewSpots view as well as the Spitcast logo
    @IBOutlet weak var footer: UIView!
    
    // this is where the SpotLibrary object is first constructed. This object will be passed to the SearchForNewSpotsController
    var spotLibrary:SpotLibrary = SpotLibrary()
    
    // usingUserDefaults is set to true when data from NSUserDefaults was used to initialize the SpotLibrary object.
    // :: when set to true, this boolean value tells the controller to download the list of spots from Spitcast.
    //    the list of spots is downloaded from Spitcast when the spotDataDictionary is empty, or when the spotDataDictionary object is not empty but only contains the spots
    //    read and restored from NSUserDefaults
    var usingUserDefaults:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the cell identifier set in the storyboard for this view
        self.yourSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "yourSpotsTableViewCell")
        
        // if data exists in NSUserDefaults under the key "userSelectedSpots", the data is restored using a SpotLibrary method
        // and the boolean variable usingUserDefaults is set to true to make YourSpotsTableViewController request a list of all spots from Spitcast.
        // reloadData() is called on this tableView if data is restored from NSUserDefaults
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
            usingUserDefaults = true
            self.spotLibrary.deserializeSpotLibraryFromString(exportString)
            self.yourSpotsTableView.reloadData()
        }
        
        // set the background color of this view to be a dark, near-black gray
        self.yourSpotsTableView.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        
        // set the header view with the on-boarding message if the user hasn't added any spots
        if self.spotLibrary.selectedSpotIDs.count == 0 {
            yourSpotsTableView.tableHeaderView = header
        }
        else {
            self.header.hidden = true
            self.yourSpotsTableView.tableHeaderView = nil
        }
        
        // set footer to be the tableFooterView of yourSpotsTableView and give footer a height of 100
        footer.frame = CGRect(x: footer.frame.minX, y: footer.frame.minY, width: footer.frame.maxX, height: 130)
        yourSpotsTableView.tableFooterView = footer
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // isConnectedToNetwork returns true if the user's device has a network connection. If isConnectedToNetwork() returns false,
        // control is sent to a method that waits for a network connection to be established before returning control to viewWillAppear
        if !(isConnectedToNetwork()) {
            dispatch_to_background_queue {
                self.waitForConnection()
            }
        }
        
        // downloadMissingSpotInfo() checks to see if data for the user's selected spots has been downloaded. If data hasn't been stored
        // for the user's spots, the data is then requested from Spitcast
        downloadMissingSpotInfo()
    }
    
    // openSpitcast opens the Spitcast website in Safari when the user taps on the Spitcast logo in the footer view
    @IBAction func openSpitcast(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.spitcast.com")!)
    }
    
    // unwindToList is a segue back to this view from other views. This method updates this view's data with anything new that might have happened in another view.
    // :: The view we're coming from is stored in this method as "source". Only two views segue back to this view: SearchForNewSpots and SpotDetail. Their segues are
    //    named and identified in this method so that unwindToList operates with the right idea of where the user is coming from.
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        
        // all segues are named in interface builder and used here to decide what to do
        if segue.identifier! == "unwindFromSearchCell" || segue.identifier! == "unwindFromSearchCancelButton" {
            
            // identify the view we're coming from as the searchForNewSpots view
            var source:SearchForNewSpotsTableViewController = segue.sourceViewController as SearchForNewSpotsTableViewController
            
            // replace this controller's SpotLibrary object with the newer one coming back from the view
            self.spotLibrary = source.spotLibrary
            
            // dismiss the keyboard
            source.searchField.resignFirstResponder()
            source.dismissViewControllerAnimated(true, completion: nil)
            
            // dismiss the header view if it is still being displayed
            // and the user has selected at least once spot
            if self.tableView.tableHeaderView != nil {
                if self.spotLibrary.selectedSpotIDs.count > 0 {
                    self.header.hidden = true
                    self.tableView.tableHeaderView = nil
                }
            }
            
            // reload this table view's data with the new SpotLibrary object
            self.tableView.reloadData()
            self.downloadMissingSpotInfo()
            
        }
        else if segue.identifier! == "unwindFromSpotDetail" {
            // as of now, do nothing
        }
    }
    
    // waitForConnection waits for a network connection to be established before returning control to viewWillAppear
    func waitForConnection() {
        
        // connectedToNetwork is false until set to true to by the waiting while loop
        var connectedToNetwork:Bool = false
        
        // this loop waits for a network connection to be made, when it will set connectedToNetwork to true and break the while loop
        while !(connectedToNetwork) {
            if isConnectedToNetwork() {
                connectedToNetwork = true
            }
        }
        
        // control is sent back to viewWillAppear
        self.viewWillAppear(false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // only one section here
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of rows comes from the count of array selectedSpotIDs in this controller's current SpotLibrary object
        return spotLibrary.selectedSpotIDs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // this is the ID of the cell at this indexPath
        let rowID = self.spotLibrary.selectedSpotIDs[indexPath.row]
        
        // create cell object as an instance of YourSpotsCell
        let cell:YourSpotsCell = yourSpotsTableView.dequeueReusableCellWithIdentifier("yourSpotsCell", forIndexPath: indexPath) as YourSpotsCell
        
        // clear the cell's background before the cell is assigned a background gradient
        cell.backgroundColor = UIColor.clearColor()
        
        // clip bounds
        cell.clipsToBounds = true
        
        // if values have been stored this cell's spot pass this data to the cell
        if let spotValues = self.spotLibrary.allSpotDataIfRequestsComplete(rowID) {
            cell.setCellLabels(self.spotLibrary.nameForSpotID(rowID), values: spotValues)
        }
        else {
            
            // if getValuesForYourSpotsCell is returning nil, this means that all of the data for the spot that is being
            // display at this cell hasn't been stored yet. In this case, we pass setCellLabels the name of the spot,
            // to display to the user that their cell was successfully added to their list and nil for valuesForSpotAtThisCell.
            // setCellLabels will gracefully display a blank cell when receiving nil for valuesForSpotAtTheCell while we wait
            // for data to be stored for this spot
            cell.setCellLabels(self.spotLibrary.nameForSpotID(rowID), values: nil)
            
            // a reloadData() call is attached to the end of the main_queue, or the UI thread, to allow us to return to
            // cellForRowAtIndexPath. When we return, if valuesForSpotAtThisCell does not return nil, then it's value are passed to setCellLabels,
            // the cell is displayed, and we can move on from this cell. If valuesForSpotAtTheCell is nil, another reloadData is attached to the end of the
            // UI thread and we repeat.
            dispatch_to_main_queue {
                self.yourSpotsTableView.reloadData()
            }
        }
        
        // return the cell object. At this point, setCellLabels has completed and returned control
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // give the first cell a taller height to give the cell padding beneath the status bar
        if indexPath.row == 0 {
            return 97.0
        }
            
            // give every other cell a height that is slightly smaller
        else {
            return 76.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        // this is the ID of the cell at this indexPath
        let rowID = self.spotLibrary.selectedSpotIDs[indexPath.row]
        
        // if values have been stored this cell's spot, perform the segue to the spot details controller
        if let spotValues = self.spotLibrary.allSpotDataIfRequestsComplete(rowID) {
            self.performSegueWithIdentifier("openSpotDetail", sender: nil)
        }
        
        // visually deselect the cell
        yourSpotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool  {
        return self.spotLibrary.selectedSpotIDs.count > 1
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.spotLibrary.selectedSpotIDs.count == 1
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // begin updates to the table view's data
        tableView.beginUpdates()
        
        // mark the source cell that is being moved
        let source = self.spotLibrary.selectedSpotIDs[sourceIndexPath.row]
        
        // mark the destination cell that this cell is being moved to
        let destination = self.spotLibrary.selectedSpotIDs[destinationIndexPath.row]
        
        // switch the two spot ID's in the data source
        self.spotLibrary.selectedSpotIDs[sourceIndexPath.row] = destination
        self.spotLibrary.selectedSpotIDs[destinationIndexPath.row] = source
        
        // end updates to the table view
        tableView.endUpdates()
    }
    
    // swipe to delete is enabled for this table view
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // begin updates to the tableView's data
            self.yourSpotsTableView.beginUpdates()
            
            // delete the entry in selectedSpotIDs in the SpotLibrary object
            spotLibrary.selectedSpotIDs.removeAtIndex(indexPath.row)
            
            // remove the row from the table
            yourSpotsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            
            // end updates to the tableView's data
            self.yourSpotsTableView.endUpdates()
            
            // set the background for each visible table cell in the table to the be the size of the cell. This method maintains consistency
            // on the table view after deleting a cell causes the heights of the first and second cell to change.
            for cell in self.yourSpotsTableView.visibleCells() as [YourSpotsCell] {
                cell.gradient.frame = cell.bounds
            }
        }
    }
    
    // set the statusBar's fill to white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // prepareForSegue is called before a segue is completed to another view.
    // :: this method is used to pass data between this view controller and the destination view controller.
    // :: The view we're moving to is stored in this method as destinationView. segues are named and identified 
    //    in this method so that unwindToList operates with the right idea of where the user is coming from.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        
        if segue.identifier! == "openSearchForSpots" || segue.identifier! == "openSearchForSpotsOnBoarding" {
            
            // identify destination controller
            let nav:UINavigationController = segue.destinationViewController as UINavigationController
            let destinationView:SearchForNewSpotsTableViewController = nav.topViewController as SearchForNewSpotsTableViewController
            
            // pass our SpotLibrary object to the destination view controller for a new spot to be added.
            // This will be passed back when we leave that view, whether changed or unchanged
            destinationView.spotLibrary = self.spotLibrary
        }
        if segue.identifier! == "openSpotDetail" {
            // identify destination controller
            let nav:UINavigationController = segue.destinationViewController as UINavigationController
            let destinationView:SpotDetailViewController = nav.topViewController as SpotDetailViewController
            
            // identify the row that was selected and the id of this row's spot
            let indexPath:NSIndexPath = yourSpotsTableView.indexPathForSelectedRow()!
            let rowID = self.spotLibrary.selectedSpotIDs[indexPath.row]
            
            // pass our SpotLibrary object to the destination view controller to access spot data
            destinationView.spotLibrary = self.spotLibrary
            
            // pass the id of the selected spot to the destination view controller
            destinationView.selectedSpotID = rowID
        }
    }
    
    // downloadMissingSpotInfo() checks to see if data for the user's selected spots has been downloaded. 
    // :: if data hasn't been stored for the spots the user has selected, the data is then requested from Spitcast
    func downloadMissingSpotInfo() {
        
        // request the list of counties and spots after initializing a SpotLibrary object. This runs if a SpotLibrary
        // object has an empty spotDataDictionary, or if the SpotLibrary object was initialized from data stored in NSUserDefaults
        if spotLibrary.spotDataByID.isEmpty || usingUserDefaults {
            if isConnectedToNetwork() {
                dispatch_to_background_queue {
                    self.spotLibrary.getCountyNames()
                }
                
                // set usingUserDefaults to false now that spots and counties have been requested from Spitcast
                usingUserDefaults = false;
            }
        }
        
        // if the user has selected any spots
        if spotLibrary.selectedSpotIDs.count > 0 {
            
            // loop through each id in the list of selectedSpot
            for spot in spotLibrary.selectedSpotIDs {
                
                // if there is an internet connection
                if isConnectedToNetwork() {
                    
                    if self.spotLibrary.allSpotDataIfRequestsComplete(spot) == nil {
                        dispatch_to_background_queue {
                            self.spotLibrary.getSpotHeightsForToday(spot)
                            let county = self.spotLibrary.countyForSpotID(spot)
                            self.spotLibrary.getCountyWaterTemp(county)
                            self.spotLibrary.getCountyTideForToday(county)
                            self.spotLibrary.getCountySwell(county)
                            self.spotLibrary.getCountyWind(county)
                        }
                        
                        dispatch_to_main_queue {
                            self.yourSpotsTableView.reloadData()
                        }
                    }
                    
//                    // request spot data on a separate thread from the UI if all data for a spot has not been stored
//                    if spotLibrary.getValuesForYourSpotsCell(spot) == nil {
//                        dispatch_to_background_queue {
//                            self.spotLibrary.getSpotSwellsForToday(spot)
//                            self.spotLibrary.getCountyWaterTemp(self.spotLibrary.county(spot))
//                            self.spotLibrary.getCountyTideForToday(self.spotLibrary.county(spot))
//                            self.spotLibrary.getCountySwell(self.spotLibrary.county(spot))
//                            self.spotLibrary.getCountyWind(self.spotLibrary.county(spot))
//                        }
//                        
//                        // call reloadData() on tableView to refresh with any new data
//                        dispatch_to_main_queue {
//                            self.yourSpotsTableView.reloadData()
//                        }
//                    }
                }
            }
        }
    }
}

