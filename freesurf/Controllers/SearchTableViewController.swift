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

class SearchTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var spotLibrary: SpotLibrary
    var results: [Int] = []
    var delegate: SearchResultDelegate
    
    var searchTableView = UITableView(frame: CGRect.zero, style: .plain)
    let searchField = UITextField()
    var nearbyIndicator = UIActivityIndicatorView()
    
    init(spotLibrary: SpotLibrary, delegate: SearchResultDelegate) {
        self.spotLibrary = spotLibrary
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.prompt = "Enter name of county or surf spot"
        
        view.addSubview(searchTableView)
        searchTableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.centerX.equalTo(view.snp.centerX)
        }
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        searchTableView.backgroundColor = UIColor.clear
        
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView:UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = searchTableView.bounds
        searchTableView.backgroundView = blurEffectView
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Nearby", style: .plain, target: self, action: #selector(SearchTableViewController.tappedNearby))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.didTapCancel))
        cancelButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = cancelButton
        display(resultsForSearch: "")
        
        searchField.frame = CGRect(x: 60, y: 37, width: 240, height: 30)
        searchField.backgroundColor = UIColor.black
        searchField.textColor = UIColor.white
        searchField.borderStyle = .roundedRect
        searchField.keyboardAppearance = .dark
        navigationItem.titleView = searchField
        
        searchField.addTarget(self, action: #selector(editingchanged(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchField.becomeFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = searchTableView.dequeueReusableCell(withIdentifier: "searchCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "searchCell")
        }
        let rowID = self.results[(indexPath as NSIndexPath).row]
        
        cell?.textLabel?.text = spotLibrary.spotDataByID[rowID]!.name
        cell?.textLabel?.textColor = UIColor.white
        cell?.detailTextLabel?.text = spotLibrary.spotDataByID[rowID]!.county
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchField.resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
        delegate.did(selectSpotId: results[indexPath.row])
    }
    
    @objc func didTapCancel() {
        searchField.resignFirstResponder()
        searchField.endEditing(false)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func editingchanged(_ sender: UITextField) {
        guard let input = sender.text else {
            return
        }
        display(resultsForSearch: input.lowercased())
    }
    
    private func display(resultsForSearch searchText: String) {
        if searchText == "" {
            results = spotLibrary.spotDataByID.keys.map({ self.spotLibrary.spotDataByID[$0]! }).sorted(by: { $0.name < $1.name }).map({ $0.id })
        } else {
            results = spotLibrary.spotDataByID.keys.map({ self.spotLibrary.spotDataByID[$0]! }).sorted(by: { $0.name < $1.name }).filter({ $0.name.lowercased().contains(searchText) || $0.county.lowercased().contains(searchText)}).map({ $0.id })
        }
        
        self.searchTableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // only hide the scroll view on drag if there is at least one result being displayed.
        // otherwise, the user may be confused why the keyboard hid and would have to tap the search field before typing
        if results.count > 0 {
            self.searchField.resignFirstResponder()
        }
    }
    
    func tappedNearby() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
