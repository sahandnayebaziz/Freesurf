//
//  AddNewSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class AddNewSpotsTableViewController: UITableViewController, NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var addNewSpotsTableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var addSpotLibrary:SpotLibrary = SpotLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNewSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "addNewSpotCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addSpotLibrary.allWaveIDs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = addSpotLibrary.allWaveIDs[indexPath.row]
        var cell:UITableViewCell = self.addNewSpotsTableView.dequeueReusableCellWithIdentifier("addNewSpotCell") as UITableViewCell
        cell.textLabel!.text = addSpotLibrary.name(rowID)
        if contains(addSpotLibrary.selectedWaveIDs, rowID) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let rowID = addSpotLibrary.allWaveIDs[indexPath.row]
        addNewSpotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
        if contains(addSpotLibrary.selectedWaveIDs, rowID) {
            addSpotLibrary.selectedWaveIDs.removeAtIndex(find(addSpotLibrary.selectedWaveIDs, rowID)!)
        }
        else {
            addSpotLibrary.selectedWaveIDs.append(rowID)
            if isConnectedToNetwork() {
                dispatch_to_background_queue {
                    self.addSpotLibrary.getSwell(rowID)
                }
            }
        }
        self.addNewSpotsTableView.reloadData()
        
    }
}