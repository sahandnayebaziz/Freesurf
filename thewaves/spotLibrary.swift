//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SpotLibrary: NSObject, NSURLSessionDelegate {
    var waveDataDictionary:[Int:(spotName:String, spotHeight:Int)] = [:]
    var allWaveIDs:[Int] = []
    var selectedWaveIDs:[Int] = []
    
    init(getSwellData:Bool) {
        super.init()
        if (getSwellData) {
            self.getSpots()
        }
    }
    
    func getSpots() {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/orange-county/")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        })
        sourceTask.resume()
        sleep(1)
        let numberInData:Int! = sourceData?.count!
        for var index = 0; index < numberInData; index++ {
            let newSpotName:String = sourceData![index]!["spot_name"]! as String
            let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
            //add to dictionary
            self.waveDataDictionary[newSpotID] = (newSpotName, 0)
            self.allWaveIDs.append(newSpotID)
        }
    }
    
    func getSwell(spotID:Int) {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        var newHeightMap:[(spotID:Int, height:Int)] = []
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        })
        sourceTask.resume()
        sleep(1)
        let newHeight:Int = sourceData![10]!["size"]! as Int
        self.waveDataDictionary[spotID]!.spotHeight = newHeight
    }
}



























