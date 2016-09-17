//
//  SpotsViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import SnapKit
import ReachabilitySwift

class SpotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SpotDataDelegate, SpotTableViewDelegate, SearchResultDelegate, UISplitViewControllerDelegate, FooterViewDelegate {
    
    var library: SpotLibrary!
    var usingUserDefaults:Bool = false
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var collapseDetailViewController = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        library = SpotLibrary(dataDelegate: self, tableViewDelegate: self)
        
        title = "Spots"
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.centerX.equalTo(view.snp.centerX)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        tableView.register(SpotCell.self, forCellReuseIdentifier: "spotCell")
        
        splitViewController?.delegate = self
        
        library.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return FooterView(delegate: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.selectedSpotIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath) as! SpotCell
        let spotId = library.selectedSpotIDs[indexPath.row]
        let spot = library.spotDataByID[spotId]!
        cell.set(forSpot: spot)
        cell.did(updateSpot: spot)
        cell.did(updateCounty: library.countyDataByName[spot.county]!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        collapseDetailViewController = false
        self.performSegue(withIdentifier: "openSpotDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            library.delete(spotAtIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
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
        
//        source.searchField.resignFirstResponder()
        source.dismiss(animated: true, completion: nil)
    }
    
    func didTapAdd() {
        let vc = SearchTableViewController(spotLibrary: library, delegate: self)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        nav.view.backgroundColor = UIColor.clear
        present(nav, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier! == "openSpotDetail" {
            let destination = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            let spotId = library.selectedSpotIDs[(tableView.indexPathForSelectedRow!).row]
            let spot = library.spotDataByID[spotId]!
            let county = library.countyDataByName[spot.county]!
            destination.did(updateSpot: spot)
            destination.did(updateCounty: county)
        }
    }
    
    func didLoadSavedSpots(spotsFound: Bool) {
        if spotsFound {
            usingUserDefaults = true
            tableView.reloadData()
        }
    }
    
    func did(selectSpotId spotId: Int) {
        library.select(spotWithId: spotId).then { result -> Void in
            if result.didAddSpot {
                self.tableView.reloadData()
                self.library.get(dataForSpotId: spotId)
            }
        }
    }
    
    func did(updateSpot spot: SpotData) {
        guard let visibleCells = tableView.visibleCells as? [SpotCell] else {
            NSLog("Unable to get visible cells.")
            return
        }
        
        for cell in visibleCells {
            cell.did(updateSpot: spot)
        }
    }
    
    func did(updateCounty county: CountyData) {
        guard let visibleCells = tableView.visibleCells as? [SpotCell] else {
            NSLog("Unable to get visible cells.")
            return
        }
        
        for cell in visibleCells {
            cell.did(updateCounty: county)
        }
    }
}

