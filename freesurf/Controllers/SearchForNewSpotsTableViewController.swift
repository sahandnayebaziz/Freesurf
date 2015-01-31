//
//  SearchForNewSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 9/26/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SearchForNewSpotsTableViewController: UITableViewController, UIScrollViewDelegate {
    @IBOutlet var searchForNewSpotsTableView: UITableView! // this is the table view
    @IBOutlet weak var searchField: UITextField! // this is the text field used for input
    var spotLibrary:SpotLibrary! // this is the SpotLibrary object that always comes from the first view controller
    var results:[Int] = [] // this is an array that is populated by spots that contain the string the user has entered into the text field
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchForNewSpotsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.searchForNewSpotsTableView.backgroundColor = UIColor.clearColor()
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = searchForNewSpotsTableView.bounds
        self.searchForNewSpotsTableView.backgroundView = blurEffectView
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchField.becomeFirstResponder() // this calls up the keyboard for the search text field
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count // returns the number of spots that have matched with the input string
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = self.results[indexPath.row] // helper to store the spotID of the spot being displayed at given row
        
        // create and return a cell that displays the name and county name of a spot for this match in the results array
        var cell:UITableViewCell = self.searchForNewSpotsTableView.dequeueReusableCellWithIdentifier("searchForNewSpotsCell") as UITableViewCell
        cell.textLabel!.text = spotLibrary.nameForSpotID(rowID)
        cell.detailTextLabel!.text = spotLibrary.countyForSpotID(rowID)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchField.resignFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender!.isKindOfClass(UIBarButtonItem) {
            // do nothing
        }
        if sender!.isKindOfClass(UITableViewCell) {
            var indexPath:NSIndexPath = searchForNewSpotsTableView.indexPathForSelectedRow()!
            if !(contains(self.spotLibrary.selectedSpotIDs, results[indexPath.row])) {
                spotLibrary.selectedSpotIDs.append(results[indexPath.row])
            }
        }
    }
    
    // this function runs on every keystroke in the searchField
    @IBAction func editingchanged(sender: UITextField) {
        // capture the input and empty the results array before we match with this new input
        let input:String = sender.text
        self.results = []
        
        // if the user has entered at least one character, search for all spots with
        // a name or a county containing the input string. Add all of those to the results array
        if (countElements(sender.text) != 0) {
            for key in self.spotLibrary.spotDataByID.keys {
                if (self.spotLibrary.spotDataByID[key]!.spotName.contains(input) || self.spotLibrary.spotDataByID[key]!.spotCounty.contains(input)) {
                    self.results.append(key)
                }
            }
        }
        
        // reload the table view to display the new matches in the cells
        self.searchForNewSpotsTableView.reloadData()
    }
}