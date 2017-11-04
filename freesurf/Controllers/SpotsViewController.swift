//
//  SpotsViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import SnapKit
import Reachability

class SpotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SpotDataDelegate, SpotTableViewDelegate, SearchResultDelegate, UISplitViewControllerDelegate, FooterViewDelegate, UIViewControllerPreviewingDelegate {
    
    var library: SpotLibrary!
    
    let tableView = LPRTableView(frame: CGRect.zero, style: .grouped)
    var collapseDetailViewController = true
    
    var detailView: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Spots"
        
        splitViewController!.navigationController?.navigationBar.barStyle = .black
        splitViewController?.delegate = self
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        library = SpotLibrary(dataDelegate: self, tableViewDelegate: self)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.size.equalTo(view.safeAreaLayoutGuide)
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.sectionHeaderHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        tableView.register(SpotCell.self, forCellReuseIdentifier: "spotCell")
        
        library.loadData()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.visibleCells.forEach({ $0.setNeedsDisplay() })
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
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
        if let county = library.countyDataByName[spot.county] {
            cell.did(updateCounty: county)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        collapseDetailViewController = false
        
        let spotId = library.selectedSpotIDs[indexPath.row]
        let spot = library.spotDataByID[spotId]!
        
        let vc = DetailViewController(forSpot: spot)
        detailView = vc
        let nav = UINavigationController(rootViewController: vc)
        vc.did(updateSpot: spot)
        if let county = library.countyDataByName[spot.county] {
            vc.did(updateCounty: county)
        }
        splitViewController?.showDetailViewController(nav, sender: nil)
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
            
            if library.selectedSpotIDs.isEmpty {
                guard let splitViewController = splitViewController else {
                    return
                }
                
                guard splitViewController.viewControllers.count == 2 else {
                    return
                }
                
                guard let detailView = ((splitViewController.viewControllers[1] as? UINavigationController)?.topViewController as? DetailViewController) else {
                    return
                }
                
                detailView.setForNoSpot()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let spot = library.selectedSpotIDs[sourceIndexPath.row]
        library.selectedSpotIDs.remove(at: sourceIndexPath.row)
        library.selectedSpotIDs.insert(spot, at: destinationIndexPath.row)
        library.saveSelectedSpotsToDefaults()
    }

    func didTapAdd() {
        let vc = SearchTableViewController(spotLibrary: library, delegate: self)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.clear
        nav.view.backgroundColor = UIColor.clear
        present(nav, animated: true, completion: nil)
    }
    
    func didLoadSavedSpots(spotsFound: Bool) {
        if spotsFound {
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
            return
        }
        
        for cell in visibleCells {
            cell.did(updateSpot: spot)
        }
        
        detailView?.did(updateSpot: spot)
    }
    
    func did(updateCounty county: CountyData) {
        guard let visibleCells = tableView.visibleCells as? [SpotCell] else {
            return
        }
        
        for cell in visibleCells {
            cell.did(updateCounty: county)
        }
        
        detailView?.did(updateCounty: county)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let spotId = library.selectedSpotIDs[indexPath.row]
        let spot = library.spotDataByID[spotId]!
        
        let vc = DetailViewController(forSpot: spot)
        let nav = UINavigationController(rootViewController: vc)
        vc.did(updateSpot: spot)
        if let county = library.countyDataByName[spot.county] {
            vc.did(updateCounty: county)
        }
        return nav
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

