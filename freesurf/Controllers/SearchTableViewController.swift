//
//  SearchTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 9/26/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation

protocol SearchResultDelegate {
    func did(selectSpotId spotId: Int)
}

// SearchTableViewController lets you search for and add a new spot.
class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties -
    var spotLibrary:SpotLibrary!
    var results:[Int] = []
    var delegate: SearchResultDelegate!
    
    var displayingNearby = false {
        didSet {
            if displayingNearby {
                self.navigationItem.prompt = "Now displaying nearby spots"
            }
            else {
                self.navigationItem.prompt = "Enter name of county or surf spot"
            }
        }
    }
    
    // MARK: - Interface Outlets -
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    var headerView = UIView()
    var nearbyButton = UIButton()
    var nearbyIndicator = UIActivityIndicatorView()
    
    // MARK: - View methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.searchTableView.backgroundColor = UIColor.clear
        self.displayingNearby = false
        
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = searchTableView.bounds
        self.searchTableView.backgroundView = blurEffectView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Nearby", style: .plain, target: self, action: #selector(SearchTableViewController.tappedNearby))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchField.becomeFirstResponder()
    }
    
    // MARK: - Interface Actions -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UITableViewCell {
            guard let row = searchTableView.indexPathForSelectedRow?.row else {
                NSLog("Error selecting row")
                return
            }
            
            delegate.did(selectSpotId: results[row])
        }
    }
    
    @IBAction func editingchanged(_ sender: UITextField) {
        let input = sender.text!.lowercased()
        self.displayingNearby = false
        results = spotLibrary.spotDataByID.keys.map({ self.spotLibrary.spotDataByID[$0]! }).filter({ $0.name.lowercased().contains(input) || $0.county.lowercased().contains(input)}).map({ $0.id })
        self.searchTableView.reloadData()
    }
    
    func tappedNearby() {
        self.searchField.resignFirstResponder()
//        dispatch_to_main_queue {
//            self.searchField.text = ""
//            self.searchField.resignFirstResponder()
//            self.tableView.backgroundView?.addSubview(self.nearbyIndicator)
//            self.nearbyIndicator.hidesWhenStopped = true
//            self.nearbyIndicator.snp.makeConstraints { make in
//                make.centerX.equalTo(self.tableView.snp.centerX)
//                make.centerY.equalTo(self.tableView.snp.centerY).offset(-100)
//            }
//            self.nearbyIndicator.startAnimating()
//            
//            SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 5, onSuccess: { (location) -> Void in
//                if let location = location {
//                    self.displayingNearby = true
//                    self.currentLocation = location
//                    self.listNearbySpots()
//                }
//                
//            }) { (error) -> Void in
//                NSLog("\(error)")
//            }
//        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayingNearby ? 13 : results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowID = self.results[(indexPath as NSIndexPath).row]
        
        let cell:UITableViewCell = self.searchTableView.dequeueReusableCell(withIdentifier: "searchCell") as UITableViewCell!
        
        cell.textLabel!.text = spotLibrary.spotDataByID[rowID]!.name
        cell.detailTextLabel!.text = spotLibrary.spotDataByID[rowID]!.county
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // only hide the scroll view on drag if there is at least one result being displayed.
        // otherwise, the user may be confused why the keyboard hid and would have to tap the search field before typing
        if results.count > 0 {
            self.searchField.resignFirstResponder()
        }
    }
    
    func nearer(_ id1:Int, id2:Int) -> Bool {
//        if let l1 = self.spotLibrary.locationForSpotID(id1), let l2 = self.spotLibrary.locationForSpotID(id2) {
//            return currentLocation.distance(from: l1) < currentLocation.distance(from: l2)
//        }
//        else {
//            return false
//        }
        return true
    }
    
    func listNearbySpots() {
        if !self.spotLibrary.spotDataByID.keys.isEmpty {
            results = self.spotLibrary.spotDataByID.keys.sorted(by: nearer)
            dispatch_to_main_queue {
                self.nearbyIndicator.stopAnimating()
                self.nearbyIndicator.removeFromSuperview()
            }
            self.searchTableView.reloadData()
        }
    }
}
