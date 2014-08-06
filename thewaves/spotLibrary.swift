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
    var selectedSpotsDictionary:[Int:(name:String, isAdded:Bool)]
    
    override init() {
        selectedSpotsDictionary = [:]
        spotIDMap = []
        super.init()
        self.getSpots()
    }
    
    init(empty:String) {
        selectedSpotsDictionary = [:]
        spotIDMap = []
        super.init()
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
            let newSpotName:String = sourceData![index]!["spot_name"]! as String
            let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
            
            //add to list
            newSpotIDMap.append((spotName:newSpotName, spotID:newSpotID))
            
            //add to dictionary
            selectedSpotsDictionary[newSpotID] = (newSpotName, false)
        }
        //replace with loaded list
        self.spotIDMap = newSpotIDMap
    }
}
