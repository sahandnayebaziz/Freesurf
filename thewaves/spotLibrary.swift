//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import Foundation

class SpotLibrary: NSObject, NSURLSessionDelegate {
    var spotIDMap:[(spotName:String, spotID:Int)]
    var selectedSpotsDictionary:[String:Int]
    var selectedSpotsArray:[(String, Int)]
    
    init() {
        selectedSpotsDictionary = [:]
        selectedSpotsArray = []
        spotIDMap = []
        super.init()
    }
    
    init(county:String) {
        selectedSpotsDictionary = [:]
        selectedSpotsArray = []
        spotIDMap = []
        super.init()
        self.getSpots()
    }
    
    func getSpots() {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/orange-county/")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        var newSpotIDMap:[(spotName:String, spotID:Int)] = []
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        })
        sourceTask.resume()
        sleep(1)
        let numberInData:Int! = sourceData?.count!
        for var index = 0; index < numberInData; index++ {
            let spotName:String = sourceData![index]!["spot_name"]! as String
            let spotID:Int = sourceData![index]!["spot_id"]! as Int
            var newSpot = (spotName, spotID)
            newSpotIDMap += newSpot
        }
        self.spotIDMap = newSpotIDMap
    }
}




//
//func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
//    var cell:UITableViewCell = self.mainTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
//    cell.textLabel.text = self.spotNames[indexPath.row]
//    return cell
//}
//
//func tableView(tableView: UITableView!, didDeselectRowAtIndexPath indexPath: NSIndexPath!)  {
//}
//
//func forwards(s1: String, s2: String) -> Bool
//{
//    return s1 < s2
//}