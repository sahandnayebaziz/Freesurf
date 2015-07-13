//
//  SpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SpotsTableViewController: UITableViewController, LPRTableViewDelegate, SpotLibraryDelegate, UISplitViewControllerDelegate {
    
    // MARK: - Properties -
    var spotLibrary:SpotLibrary = SpotLibrary()
    var reachability = Reachability.reachabilityForInternetConnection()
    var usingUserDefaults:Bool = false
    var collapseDetailViewController = true
    
    // MARK: - Interface Outlets -
    @IBOutlet var spotsTableView: LPRTableView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var footer: UIView!
    
    // MARK: - View Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spotLibrary.delegate = self
        splitViewController?.delegate = self
        
        self.configureViewStyle()
        self.configureNetwork()
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return collapseDetailViewController
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func configureViewStyle() {
        self.spotsTableView.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        
        // add onboarding header if no spots have been added
        self.readSavedSpots()
        if self.spotLibrary.selectedSpotIDs.count == 0 { spotsTableView.tableHeaderView = header }
        else {
            self.header.hidden = true
            self.spotsTableView.tableHeaderView = nil
        }
        footer.frame = CGRect(x: footer.frame.minX, y: footer.frame.minY, width: footer.frame.maxX, height: 130)
        spotsTableView.tableFooterView = footer
    }
    
    func configureNetwork() {
        if reachability.isReachable() {
            self.downloadMissingSpotInfo()
        }
        
        reachability.whenReachable = { reachability in
            self.downloadMissingSpotInfo()
        }
        reachability.whenUnreachable = { reachability in
            NSLog("Became unreachable")
        }
        
        reachability.startNotifier()
    }
    
    // MARK: - Delegate methods -
    func didDownloadDataForSpot() {
        self.tableView.reloadData()
    }
    
    // MARK: - Interface Actions -
    @IBAction func openSpitcast(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.spitcast.com")!)
    }
    
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        if segue.identifier! == "unwindFromSearchCell" || segue.identifier! == "unwindFromSearchCancelButton" {
            
            var source:SearchTableViewController = segue.sourceViewController as! SearchTableViewController
            source.spotLibrary = self.spotLibrary
            
            source.searchField.resignFirstResponder()
            source.dismissViewControllerAnimated(true, completion: nil)
            
            if self.tableView.tableHeaderView != nil {
                if self.spotLibrary.selectedSpotIDs.count > 0 {
                    self.header.hidden = true
                    self.tableView.tableHeaderView = nil
                }
            }
            
            self.tableView.reloadData()
            self.downloadMissingSpotInfo()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier! == "openSearchForSpots" || segue.identifier! == "openSearchForSpotsOnBoarding" {
            let nav:UINavigationController = segue.destinationViewController as! UINavigationController
            let destinationView:SearchTableViewController = nav.topViewController as! SearchTableViewController
            
            destinationView.spotLibrary = self.spotLibrary
        }
        
        if segue.identifier! == "openSpotDetail" {
            let nav:UINavigationController = segue.destinationViewController as! UINavigationController
            var destinationView:DetailViewController = nav.topViewController as! DetailViewController
            
            let indexPath:NSIndexPath = spotsTableView.indexPathForSelectedRow()!
            let rowID = self.spotLibrary.selectedSpotIDs[indexPath.row]
            
            let model = DetailViewModel(values: self.spotLibrary.allDetailViewData(rowID))
            destinationView.model = model
            destinationView.selectedSpotID = rowID
            destinationView.currentHour = NSDate().hour()
        }
    }
    
    // MARK: - Table View Methods -
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotLibrary.selectedSpotIDs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = self.spotLibrary.selectedSpotIDs[indexPath.row]
        
        var model:SpotCellViewModel
        if let values = self.spotLibrary.allSpotCellDataIfRequestsComplete(rowID) {
            model = SpotCellViewModel(name: spotLibrary.nameForSpotID(rowID), height: values.height, waterTemp: values.waterTemp, swell: values.swell, requestsComplete: true)
        }
        else {
            model = SpotCellViewModel(name: spotLibrary.nameForSpotID(rowID), height: nil, waterTemp: nil, swell: nil, requestsComplete: false)
        }
        
        let cell:SpotCell = spotsTableView.dequeueReusableCellWithIdentifier("spotCell", forIndexPath: indexPath) as! SpotCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.setValues(model)
        cell.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        collapseDetailViewController = false
        let rowID = self.spotLibrary.selectedSpotIDs[indexPath.row]
        
        if self.spotLibrary.allSpotCellDataIfRequestsComplete(rowID) != nil {
            self.performSegueWithIdentifier("openSpotDetail", sender: nil)
        }
        
        spotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool  {
        return self.spotLibrary.selectedSpotIDs.count > 1
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.spotLibrary.selectedSpotIDs.count == 1
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        tableView.beginUpdates()
        
        let source = self.spotLibrary.selectedSpotIDs[sourceIndexPath.row]
        let destination = self.spotLibrary.selectedSpotIDs[destinationIndexPath.row]
        
        self.spotLibrary.selectedSpotIDs[sourceIndexPath.row] = destination
        self.spotLibrary.selectedSpotIDs[destinationIndexPath.row] = source
        
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.spotsTableView.beginUpdates()
            
            spotLibrary.selectedSpotIDs.removeAtIndex(indexPath.row)
            spotsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            
            self.spotsTableView.endUpdates()
            
            for cell in self.spotsTableView.visibleCells() as! [SpotCell] { cell.gradient.frame = cell.bounds }
        }
    }
    
    // MARK: - Methods -
    func readSavedSpots() {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
            usingUserDefaults = true
            self.spotLibrary.deserializeSpotLibraryFromString(exportString)
            self.spotsTableView.reloadData()
        }
    }
    
    func downloadMissingSpotInfo() {
        if reachability.isReachable() {
            if spotLibrary.spotDataByID.isEmpty || usingUserDefaults {
                dispatch_to_background_queue {
                    self.spotLibrary.getCountyNames()
                }
                
                usingUserDefaults = false;
            }
            
            if spotLibrary.selectedSpotIDs.count > 0 {
                for spot in spotLibrary.selectedSpotIDs {
                    if self.spotLibrary.allSpotCellDataIfRequestsComplete(spot) == nil {

                        dispatch_to_background_queue {
                            self.spotLibrary.getSpotHeightsForToday(spot)
                            let county = self.spotLibrary.countyForSpotID(spot)
                            self.spotLibrary.getCountyWaterTemp(county, spotSender: spot)
                            self.spotLibrary.getCountyTideForToday(county, spotSender: spot)
                            self.spotLibrary.getCountySwell(county, spotSender: spot)
                            self.spotLibrary.getCountyWind(county, spotSender: spot)
                        }
                    }
                }
            }
        }
    }
}

