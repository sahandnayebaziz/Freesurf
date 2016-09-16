//
//  SpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import ReachabilitySwift

class SpotsTableViewController: UITableViewController, SpotLibraryDelegate, UISplitViewControllerDelegate {
    
    // MARK: - Properties -
    var spotLibrary:SpotLibrary = SpotLibrary()
    var reachability = Reachability()!
    var usingUserDefaults:Bool = false
    var collapseDetailViewController = true
    
    // MARK: - Interface Outlets -
    @IBOutlet var spotsTableView: UITableView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var footer: UIView!
    
    // MARK: - View Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spotLibrary.delegate = self
        splitViewController?.delegate = self
        
        self.configureViewStyle()
        self.configureNetwork()
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func configureViewStyle() {
        self.spotsTableView.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        
        // add onboarding header if no spots have been added
        self.readSavedSpots()
        if self.spotLibrary.selectedSpotIDs.count == 0 { spotsTableView.tableHeaderView = header }
        else {
            self.header.isHidden = true
            self.spotsTableView.tableHeaderView = nil
        }
        footer.frame = CGRect(x: footer.frame.minX, y: footer.frame.minY, width: footer.frame.maxX, height: 130)
        spotsTableView.tableFooterView = footer
    }
    
    func configureNetwork() {
        if reachability.isReachable {
            self.downloadMissingSpotInfo()
        }
        
        reachability.whenReachable = { reachability in
            self.downloadMissingSpotInfo()
        }
        reachability.whenUnreachable = { reachability in
            NSLog("Became unreachable")
        }
        
        do {
         try reachability.startNotifier()
        } catch {
            
        }
    }
    
    // MARK: - Delegate methods -
    func didDownloadDataForSpot() {
        self.tableView.reloadData()
    }
    
    // MARK: - Interface Actions -
    @IBAction func openSpitcast(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.spitcast.com")!)
    }
    
    @IBAction func unwindToList(_ segue:UIStoryboardSegue) {
        if segue.identifier! == "unwindFromSearchCell" || segue.identifier! == "unwindFromSearchCancelButton" {
            
            let source:SearchTableViewController = segue.source as! SearchTableViewController
            source.spotLibrary = self.spotLibrary
            
            source.searchField.resignFirstResponder()
            source.dismiss(animated: true, completion: nil)
            
            if self.tableView.tableHeaderView != nil {
                if self.spotLibrary.selectedSpotIDs.count > 0 {
                    self.header.isHidden = true
                    self.tableView.tableHeaderView = nil
                }
            }
            
            self.tableView.reloadData()
            self.downloadMissingSpotInfo()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!)
    {
        if segue.identifier! == "openSearchForSpots" || segue.identifier! == "openSearchForSpotsOnBoarding" {
            let nav:UINavigationController = segue.destination as! UINavigationController
            let destinationView:SearchTableViewController = nav.topViewController as! SearchTableViewController
            
            destinationView.spotLibrary = self.spotLibrary
        }
        
        if segue.identifier! == "openSpotDetail" {
            let nav:UINavigationController = segue.destination as! UINavigationController
            let destinationView:DetailViewController = nav.topViewController as! DetailViewController
            
            let indexPath:IndexPath = spotsTableView.indexPathForSelectedRow!
            let rowID = self.spotLibrary.selectedSpotIDs[(indexPath as NSIndexPath).row]
            
            let model = DetailViewModel(values: self.spotLibrary.allDetailViewData(rowID))
            destinationView.model = model
            destinationView.selectedSpotID = rowID
            destinationView.currentHour = Date().hour()
        }
    }
    
    // MARK: - Table View Methods -
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotLibrary.selectedSpotIDs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowID = self.spotLibrary.selectedSpotIDs[(indexPath as NSIndexPath).row]
        
        var model:SpotCellViewModel
        if let values = self.spotLibrary.allSpotCellDataIfRequestsComplete(rowID) {
            model = SpotCellViewModel(name: spotLibrary.nameForSpotID(rowID), height: values.height, waterTemp: values.waterTemp, swell: values.swell, requestsComplete: true)
        }
        else {
            model = SpotCellViewModel(name: spotLibrary.nameForSpotID(rowID), height: nil, waterTemp: nil, swell: nil, requestsComplete: false)
        }
        
        let cell = spotsTableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath) as! SpotCell
        
        cell.backgroundColor = UIColor.clear
        cell.setValues(model)
        cell.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        collapseDetailViewController = false
        let rowID = self.spotLibrary.selectedSpotIDs[(indexPath as NSIndexPath).row]
        
        if self.spotLibrary.allSpotCellDataIfRequestsComplete(rowID) != nil {
            self.performSegue(withIdentifier: "openSpotDetail", sender: nil)
        }
        
        spotsTableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool  {
        return self.spotLibrary.selectedSpotIDs.count > 1
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.spotLibrary.selectedSpotIDs.count == 1
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableView.beginUpdates()
        
        let source = self.spotLibrary.selectedSpotIDs[(sourceIndexPath as NSIndexPath).row]
        let destination = self.spotLibrary.selectedSpotIDs[(destinationIndexPath as NSIndexPath).row]
        
        self.spotLibrary.selectedSpotIDs[(sourceIndexPath as NSIndexPath).row] = destination
        self.spotLibrary.selectedSpotIDs[(destinationIndexPath as NSIndexPath).row] = source
        
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.spotsTableView.beginUpdates()
            
            spotLibrary.selectedSpotIDs.remove(at: (indexPath as NSIndexPath).row)
            spotsTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
            
            self.spotsTableView.endUpdates()
            
            for cell in self.spotsTableView.visibleCells as! [SpotCell] { cell.gradient.frame = cell.bounds }
        }
    }
    
    // MARK: - Methods -
    func readSavedSpots() {
        let defaults:UserDefaults = UserDefaults.standard
        
        if let exportString = defaults.object(forKey: "userSelectedSpots") as? String {
            usingUserDefaults = true
            self.spotLibrary.deserializeSpotLibraryFromString(exportString)
            self.spotsTableView.reloadData()
        }
    }
    
    func downloadMissingSpotInfo() {
        if reachability.isReachable {
            if spotLibrary.spotDataByID.isEmpty || usingUserDefaults {
                dispatch_to_background_queue {
                    self.spotLibrary.getCountyNames()
                }
                
                usingUserDefaults = false;
            }
            
            if spotLibrary.selectedSpotIDs.count > 0 {
                for spot in spotLibrary.selectedSpotIDs {
                    if self.spotLibrary.allSpotCellDataIfRequestsComplete(spot) == nil {
                        
                        dispatch_to_background_queue {
                            self.spotLibrary.getSpotHeightsForToday(spot)
                            let county = self.spotLibrary.countyForSpotID(spot)
                            self.spotLibrary.getCountyWaterTemp(county, spotSender: spot)
                            self.spotLibrary.getCountyTideForToday(county, spotSender: spot)
                            self.spotLibrary.getCountySwell(county, spotSender: spot)
                            self.spotLibrary.getCountyWind(county, spotSender: spot)
                        }
                    }
                }
            }
        }
    }
}

