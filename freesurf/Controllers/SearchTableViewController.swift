//
//  SearchTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 9/26/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import SnapKit
import WhereAmI
import PermissionScope
import CoreLocation

// SearchTableViewController lets you search for and add a new spot.
class SearchTableViewController: UITableViewController, UIScrollViewDelegate {
    
    // MARK: - Properties -
    var spotLibrary:SpotLibrary!
    var results:[Int] = []
    var currentLocation = CLLocation()
    var displayingNearby = false
    
    // MARK: - Interface Outlets -
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    var headerView = UIView()
    var nearbyButton = UIButton()
    let permissionView = PermissionScope()
    var nearbyIndicator = UIActivityIndicatorView()
    
    // MARK: - View methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.searchTableView.backgroundColor = UIColor.clearColor()
        
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = searchTableView.bounds
        self.searchTableView.backgroundView = blurEffectView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Nearby", style: .Plain, target: self, action: "tappedNearby")
        
        permissionView.addPermission(PermissionConfig(type: .LocationInUse, demands: .Required, message: "We use this to show you nearby surf spots."))
        permissionView.bodyLabel.text = "We need your permission first."
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
        self.displayingNearby = false
        self.navigationItem.prompt = "Enter name of county or surf spot"
        
        let input:String = sender.text
        
        if (count(sender.text) != 0) {
            for key in self.spotLibrary.spotDataByID.keys {
                if (self.spotLibrary.spotDataByID[key]!.name.contains(input) || self.spotLibrary.spotDataByID[key]!.county.contains(input)) {
                    self.results.append(key)
                }
            }
        }
        
        self.searchTableView.reloadData()
    }
    
    func tappedNearby() {
        self.searchField.resignFirstResponder()
        
        permissionView.show(authChange: { (finished, results) -> Void in
            if results[0].status == .Authorized {
                WhereAmI.sharedInstance.continuousUpdate = false;
                WhereAmI.sharedInstance.locationPrecision = WAILocationProfil.High
                dispatch_to_main_queue {
                    self.searchField.text = ""
                    self.searchField.resignFirstResponder()
                    self.tableView.backgroundView?.addSubview(self.nearbyIndicator)
                    self.nearbyIndicator.hidesWhenStopped = true
                    self.nearbyIndicator.snp_makeConstraints { make in
                        make.centerX.equalTo(self.tableView.snp_centerX)
                        make.centerY.equalTo(self.tableView.snp_centerY).offset(-100)
                    }
                    self.nearbyIndicator.startAnimating()
                }
                WhereAmI.whereAmI({ (location) -> Void in
                    self.displayingNearby = true
                    self.currentLocation = location
                    self.listNearbySpots()
                    
                    }, locationRefusedHandler: {() -> Void in
                        NSLog("Location access denied")
                });

            }
        })
    }
    
    // MARK: - Table view methods -
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayingNearby ? 13 : results.count
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
    
    func nearer(id1:Int, id2:Int) -> Bool {
        let l1 = self.spotLibrary.locationForSpotID(id1)
        let l2 = self.spotLibrary.locationForSpotID(id2)
        return currentLocation.distanceFromLocation(l1) < currentLocation.distanceFromLocation(l2)
    }
    
    func listNearbySpots() {
        results = sorted(self.spotLibrary.spotDataByID.keys, nearer)
        dispatch_to_main_queue {
            self.nearbyIndicator.stopAnimating()
            self.nearbyIndicator.removeFromSuperview()
        }
        self.searchTableView.reloadData()
        self.navigationItem.prompt = "Now displaying nearby spots"
    }
}
