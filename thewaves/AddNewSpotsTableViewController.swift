//
//  AddNewSpotsTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit



class AddNewSpotsTableViewController: UITableViewController, NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var addNewSpotsTableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var listOfSpots:SpotLibrary = SpotLibrary(county:"dummy")
        
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return listOfSpots.spotIDMap.count
        
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var selectedSpot = listOfSpots.spotIDMap[indexPath.row]
        var cell:UITableViewCell = self.addNewSpotsTableView.dequeueReusableCellWithIdentifier("addNewSpotCell") as UITableViewCell
        cell.textLabel.text = listOfSpots.spotIDMap[indexPath.row].spotName
        if listOfSpots.selectedSpotsDictionary[selectedSpot.spotName] {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath:NSIndexPath!) {
        var selectedSpot = listOfSpots.spotIDMap[indexPath.row]
        addNewSpotsTableView.deselectRowAtIndexPath(indexPath, animated: false)
        if listOfSpots.selectedSpotsDictionary[selectedSpot.spotName] {
            listOfSpots.selectedSpotsDictionary[selectedSpot.spotName] = nil
        }
        else {
            listOfSpots.selectedSpotsDictionary[selectedSpot.spotName] = selectedSpot.spotID
        }
        self.addNewSpotsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNewSpotsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "addNewSpotCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if sender as? NSObject == self.cancelButton {
            listOfSpots.selectedSpotsDictionary = [:]
        }
        
    }
    


    


}

//if find(elements, 5) {
//    // it was found
//}


//class ViewController: UIViewController, NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource {
//    @IBOutlet weak var mainTableView: UITableView!
//    
//    let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/orange-county/")
//    var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    var sourceData:AnyObject? = nil
//    var spotNames:[String] = []
//    
//    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
//            self.sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
//            })
//        sourceTask.resume()
//        sleep(1)
//        let numberInData:Int! = sourceData?.count!
//        for var index = 0; index < numberInData; index++ {
//            let spotName:String = sourceData![index]!["spot_name"]! as String
//            self.spotNames += spotName
//        }
//        self.spotNames = sorted(self.spotNames, forwards)
//        return numberInData
//    }
//    
//    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
//        var cell:UITableViewCell = self.mainTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
//        cell.textLabel.text = self.spotNames[indexPath.row]
//        return cell
//    }
//    
//    func tableView(tableView: UITableView!, didDeselectRowAtIndexPath indexPath: NSIndexPath!)  {
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.mainTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//    
//    
//}
//
//func forwards(s1: String, s2: String) -> Bool
//{
//    return s1 < s2
//}