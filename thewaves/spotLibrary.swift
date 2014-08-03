//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import Foundation

class spotLibrary: NSObject, NSURLSessionDelegate {
    var spotHeightDictionary:[String:Int]
    var spotIDMap:[(spotName:String, spotID:String)]
    
    init() {
        spotHeightDictionary = [:]
        spotIDMap = []
        super.init()
    }
    
    init(county:String) {
        spotHeightDictionary = [:]
        spotIDMap = []
        super.init()
        self.getSpotsByCounty("orange-county")
    }
    
    func getSpotsByCounty(county:String) -> [(spotName:String, spotID:String)] {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/" + county + "/")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        var spotIDMap:[(spotName:String, spotID:String)] = []
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        })
        sourceTask.resume()
        sleep(1)
        let numberInData:Int! = sourceData?.count!
        for var index = 0; index < numberInData; index++ {
            let spotName:String = sourceData![index]!["spot_name"]! as String
            let spotID:String = sourceData![index]!["spot_id"]! as String
            var newSpot = (spotName, spotID)
            spotIDMap += newSpot
        }
        return spotIDMap
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