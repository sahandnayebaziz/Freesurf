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
    
    @IBOutlet var yourSpotsTableView: UITableView!
    var yourSpotLibrary:SpotLibrary = SpotLibrary()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let correspondingSpot = yourSpotLibrary.spotIDMap[indexPath.row]
        var cell:UITableViewCell = self.yourSpotsTableView.dequeueReusableCellWithIdentifier("addNewSpotCell") as UITableViewCell
        cell.textLabel.text = correspondingSpot.spotName
        return cell
    }
    
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool  {
        return true
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
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

