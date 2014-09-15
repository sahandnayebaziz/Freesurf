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
    var addSpotLibrary:SpotLibrary = SpotLibrary(getSwellData: false)
    
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
        var cell:UITableViewCell = self.addNewSpotsTableView.dequeueReusableCellWithIdentifier("addNewSpotCell") as UITableViewCell
        cell.textLabel!.text = addSpotLibrary.waveDataDictionary[addSpotLibrary.allWaveIDs[indexPath.row]]!.spotName
        if contains(addSpotLibrary.selectedWaveIDs, addSpotLibrary.allWaveIDs[indexPath.row]) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        addNewSpotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
        if contains(addSpotLibrary.selectedWaveIDs, addSpotLibrary.allWaveIDs[indexPath.row]) {
            addSpotLibrary.selectedWaveIDs.removeAtIndex(find(addSpotLibrary.selectedWaveIDs, addSpotLibrary.allWaveIDs[indexPath.row])!)
        }
        else {
            addSpotLibrary.selectedWaveIDs.append(addSpotLibrary.allWaveIDs[indexPath.row])
        }
        self.addNewSpotsTableView.reloadData()
        
    }
}