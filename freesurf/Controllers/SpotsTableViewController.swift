//
//  SpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import ReachabilitySwift

class SpotsTableViewController: UITableViewController, SpotDataDelegate, SpotTableViewDelegate, SearchResultDelegate, UISplitViewControllerDelegate {
    
    var library: SpotLibrary!
    var usingUserDefaults:Bool = false
    
    @IBOutlet var spotsTableView: UITableView!
    @IBOutlet weak var footer: UIView!
    var collapseDetailViewController = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        library = SpotLibrary(delegate: self, tableViewDelegate: self)
        
        spotsTableView.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        splitViewController?.delegate = self
        
        footer.frame = CGRect(x: footer.frame.minX, y: footer.frame.minY, width: footer.frame.maxX, height: 130)
        spotsTableView.tableFooterView = footer
        
        library.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.selectedSpotIDs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = spotsTableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath) as! SpotCell
        let spotId = library.selectedSpotIDs[indexPath.row]
        let spot = library.spotDataByID[spotId]!
        cell.set(forSpot: spot)
        cell.did(updateSpot: spot)
        cell.did(updateCounty: library.countyDataByName[spot.county]!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        collapseDetailViewController = false
        let rowID = self.library.selectedSpotIDs[(indexPath as NSIndexPath).row]
        
//        if self.library.allSpotCellDataIfRequestsComplete(rowID) != nil {
//            self.performSegue(withIdentifier: "openSpotDetail", sender: nil)
//        }
//        
        spotsTableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            spotsTableView.beginUpdates()
            library.delete(spotAtIndex: indexPath.row)
            spotsTableView.deleteRows(at: [indexPath], with: .fade)
            spotsTableView.endUpdates()
        }
    }
    
    @IBAction func unwindToList(_ segue:UIStoryboardSegue) {
        guard let id = segue.identifier else {
            NSLog("Error unwinding to list.")
            return
        }
        
        guard id == "unwindFromSearchCell" || id == "unwindFromSearchCancelButton" else {
            NSLog("Error unwinding to list.")
            return
        }
        
        guard let source = segue.source as? SearchTableViewController else {
            NSLog("Error unwinding to list.")
            return
        }
        
        source.searchField.resignFirstResponder()
        source.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier! == "openSearchForSpots" || segue.identifier! == "openSearchForSpotsOnBoarding" {
            let nav:UINavigationController = segue.destination as! UINavigationController
            let destinationView:SearchTableViewController = nav.topViewController as! SearchTableViewController
            
            destinationView.spotLibrary = self.library
            destinationView.delegate = self
        }
        
        if segue.identifier! == "openSpotDetail" {
            let nav:UINavigationController = segue.destination as! UINavigationController
            let destinationView:DetailViewController = nav.topViewController as! DetailViewController
            
            let indexPath:IndexPath = spotsTableView.indexPathForSelectedRow!
            let rowID = self.library.selectedSpotIDs[(indexPath as NSIndexPath).row]

            destinationView.selectedSpotID = rowID
            destinationView.currentHour = Date().hour()
        }
    }
    
    func didLoadSavedSpots(spotsFound: Bool) {
        if spotsFound {
            usingUserDefaults = true
            spotsTableView.reloadData()
        }
    }
    
    func did(selectSpotId spotId: Int) {
        library.select(spotWithId: spotId).then { result -> Void in
            if result.didAddSpot {
                self.spotsTableView.reloadData()
                self.library.get(dataForSpotId: spotId)
            }
        }
    }
    
    func did(updateSpot spot: SpotData) {
        guard let visibleCells = spotsTableView.visibleCells as? [SpotCell] else {
            NSLog("Unable to get visible cells.")
            return
        }
        
        for cell in visibleCells {
            cell.did(updateSpot: spot)
        }
    }
    
    func did(updateCounty county: CountyData) {
        guard let visibleCells = spotsTableView.visibleCells as? [SpotCell] else {
            NSLog("Unable to get visible cells.")
            return
        }
        
        for cell in visibleCells {
            cell.did(updateCounty: county)
        }
    }
    
    @IBAction func openSpitcast(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.spitcast.com")!)
    }
}

