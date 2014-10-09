//
//  SearchForNewSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 9/26/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SearchForNewSpotsTableViewController: UITableViewController {
    @IBOutlet var searchForNewSpotsTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    var searchSpotLibrary:SpotLibrary = SpotLibrary()
    var results:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return results.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = self.results[indexPath.row]
        var cell:UITableViewCell = self.searchForNewSpotsTableView.dequeueReusableCellWithIdentifier("searchForNewSpotsCell") as UITableViewCell
        cell.textLabel!.text = searchSpotLibrary.name(rowID)
        cell.detailTextLabel!.text = searchSpotLibrary.county(rowID)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        self.searchField.resignFirstResponder()
        if !(contains(self.searchSpotLibrary.selectedSpotIDs, results[indexPath.row])) {
            searchSpotLibrary.selectedSpotIDs.append(results[indexPath.row])
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func editingchanged(sender: UITextField) {
        let input:String = sender.text
        self.results = []
        
        if (countElements(sender.text) != 0) {
            for key in self.searchSpotLibrary.spotDataDictionary.keys {
                if (self.searchSpotLibrary.spotDataDictionary[key]!.spotName.contains(input) || self.searchSpotLibrary.spotDataDictionary[key]!.spotCounty.contains(input)) {
                    self.results.append(key)
                }
            }
        }
        
        self.searchForNewSpotsTableView.reloadData()
    }
}
