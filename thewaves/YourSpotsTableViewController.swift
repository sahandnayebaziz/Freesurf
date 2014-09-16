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
    @IBOutlet weak var yourSpotsRefreshControl: UIRefreshControl!
    
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        var source:AddNewSpotsTableViewController = segue.sourceViewController as AddNewSpotsTableViewController
        self.yourSpotLibrary = source.addSpotLibrary
        self.tableView.reloadData()
    }
    
    @IBAction func fetchSwellHeights(sender: AnyObject) {
        for spot in self.yourSpotLibrary.selectedWaveIDs {
            if (self.yourSpotLibrary.height(spot) == nil) {
                self.yourSpotLibrary.getSwell(spot)
            }
        }
        yourSpotsTableView.reloadData()
        yourSpotsRefreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_to_background_queue {
            self.yourSpotLibrary.getSpots()
        }
        self.yourSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "yourSpotsTableViewCell")
        yourSpotsRefreshControl.addTarget(self, action: "fetchSwellHeights:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourSpotLibrary.selectedWaveIDs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = yourSpotLibrary.selectedWaveIDs[indexPath.row]
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "yourSpotsTableViewCell")
        cell.textLabel!.text = yourSpotLibrary.name(rowID)
        
        // remember spotHeight is an optional int, this statement checks to see if the spotHeight has been retrieved and is no longer nil.
        // if spotHeight is not nil, the height will be displayed
        if let height:Int = yourSpotLibrary.height(rowID) {
            cell.detailTextLabel!.text = "\(height)ft"
        }
            
        // if the spotHeight is still nil, an activity indicator is displayed on the cell and a reloadData() is added to the main queue
        else {
            var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            cell.accessoryView = spinner
            
            // remember getSwell, the function that retrieves the height of a spot, runs in the background. It is called when a cell in the addNewSpots view is selected.
            // since the user may return to the yourSpots view before this information has been retrieved, the table view cell is given an activity indicator to
            // show that this information is on the way. A call to reloadData is also added to the main queue to allow for the cell that's being created here to
            // be returned before the data is read once more and hopefully filled in for this spot.
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
            yourSpotLibrary.selectedWaveIDs.removeAtIndex(indexPath.row)
            yourSpotsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            self.yourSpotsTableView.endUpdates()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "openAddNewSpots") {
            var nav:UINavigationController = segue.destinationViewController as UINavigationController
            let destinationView:AddNewSpotsTableViewController = nav.topViewController as AddNewSpotsTableViewController
            destinationView.addSpotLibrary = yourSpotLibrary
        }
    }

}

