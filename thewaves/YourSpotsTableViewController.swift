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
    
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        var source:AddNewSpotsTableViewController = segue.sourceViewController as AddNewSpotsTableViewController
        self.yourSpotLibrary = source.addSpotLibrary
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
        
        if yourSpotLibrary.waveDataDictionary.isEmpty {
            if isConnectedToNetwork() {
                dispatch_to_background_queue {
                    self.yourSpotLibrary.getSpots()
                }
            }
        }
        
        if yourSpotLibrary.selectedWaveIDs.count > 0 {
            for spot in yourSpotLibrary.selectedWaveIDs {
                if yourSpotLibrary.height(spot) == nil {
                    if isConnectedToNetwork() {
                        dispatch_to_background_queue {
                            self.yourSpotLibrary.getSwell(spot)
                        }
                    }
                }
            }
        }
        
        yourSpotsTableView.reloadData()
    }
    
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
        return yourSpotLibrary.selectedWaveIDs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = yourSpotLibrary.selectedWaveIDs[indexPath.row]
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "yourSpotsTableViewCell")
        cell.textLabel!.text = yourSpotLibrary.name(rowID)
        if let height:Int = yourSpotLibrary.height(rowID) {
            cell.detailTextLabel!.text = "\(height)ft"
        }
        else {
            cell.detailTextLabel!.text = "- - ft"
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

