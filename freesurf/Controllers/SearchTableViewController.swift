//
//  SearchTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 9/26/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

// SearchTableViewController lets you search for and add a new spot.
class SearchTableViewController: UITableViewController, UIScrollViewDelegate {

    // MARK: - Properties -
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    var spotLibrary:SpotLibrary!
    var results:[Int] = []
    
    // MARK: - View methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.searchTableView.backgroundColor = UIColor.clearColor()
        
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = searchTableView.bounds
        self.searchTableView.backgroundView = blurEffectView
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchField.becomeFirstResponder()
    }
    
    // MARK: - Interface Actions -
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender!.isKindOfClass(UITableViewCell) {
            
            var indexPath:NSIndexPath = searchTableView.indexPathForSelectedRow()!
            
            if !(contains(self.spotLibrary.selectedSpotIDs, results[indexPath.row])) {
                spotLibrary.selectedSpotIDs.append(results[indexPath.row])
            }
        }
    }
    
    @IBAction func editingchanged(sender: UITextField) {
        self.results = []
        
        let input:String = sender.text

        if (count(sender.text) != 0) {
            for key in self.spotLibrary.spotDataByID.keys {
                if (self.spotLibrary.spotDataByID[key]!.spotName.contains(input) || self.spotLibrary.spotDataByID[key]!.spotCounty.contains(input)) {
                    self.results.append(key)
                }
            }
        }
        
        self.searchTableView.reloadData()
    }
    
    // MARK: - Table view methods -
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowID = self.results[indexPath.row]
        
        var cell:UITableViewCell = self.searchTableView.dequeueReusableCellWithIdentifier("searchCell") as! UITableViewCell
        
        cell.textLabel!.text = spotLibrary.nameForSpotID(rowID)
        cell.detailTextLabel!.text = spotLibrary.countyForSpotID(rowID)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // only hide the scroll view on drag if there is at least one result being displayed.
        // otherwise, the user may be confused why the keyboard hid and would have to tap the search field before typing
        if results.count > 0 {
            self.searchField.resignFirstResponder()
        }
    }
}
