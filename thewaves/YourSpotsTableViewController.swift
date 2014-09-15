//
//  YourSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class YourSpotsTableViewController: UITableViewController {
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        var source:AddNewSpotsTableViewController = segue.sourceViewController as AddNewSpotsTableViewController
        self.yourSpotLibrary = source.addSpotLibrary
        self.tableView.reloadData()
    }
    
    @IBAction func fetchSwellHeights(sender: AnyObject) {
        for spot in self.yourSpotLibrary.selectedWaveIDs {
            if (self.yourSpotLibrary.waveDataDictionary[spot]!.spotHeight == 0) {
                self.yourSpotLibrary.getSwell(spot)
            }
        }
        yourSpotsTableView.reloadData()
        yourSpotsRefreshControl.endRefreshing()
    }
    
    @IBOutlet var yourSpotsTableView: UITableView!
    @IBOutlet weak var yourSpotsRefreshControl: UIRefreshControl!
    var yourSpotLibrary:SpotLibrary = SpotLibrary()
    
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
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "yourSpotsTableViewCell")
        cell.textLabel!.text = yourSpotLibrary.waveDataDictionary[yourSpotLibrary.selectedWaveIDs[indexPath.row]]!.spotName
        let height:Int = yourSpotLibrary.waveDataDictionary[yourSpotLibrary.selectedWaveIDs[indexPath.row]]!.spotHeight
        if (height == 0) {
            cell.detailTextLabel!.text = "-"
        }
        else {
            cell.detailTextLabel!.text = "\(height)ft"
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
            yourSpotLibrary.selectedWaveIDs.removeAtIndex(find(yourSpotLibrary.selectedWaveIDs, yourSpotLibrary.selectedWaveIDs[indexPath.row])!)
            yourSpotsTableView.reloadData()
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

