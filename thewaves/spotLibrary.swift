//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

func dispatch_to_background_queue(block: dispatch_block_t?) {
    let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(q, block)
}

class SpotLibrary: NSObject, NSURLSessionDelegate {
    var waveDataDictionary:[Int:(spotName:String, spotHeight:Int)] = [:]
    var allWaveIDs:[Int] = []
    var selectedWaveIDs:[Int] = []
    
    override init() {
        super.init()
    }
    
    func getSpots() {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/orange-county/")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let numberInData = sourceData!.count
            for var index = 0; index < numberInData; index++ {
                let newSpotName:String = sourceData![index]!["spot_name"]! as String
                let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
                //add to dictionary
                self.waveDataDictionary[newSpotID] = (newSpotName, 0)
                self.allWaveIDs.append(newSpotID)
            }
        })
        sourceTask.resume()
    }
    
    func getSwell(spotID:Int) {
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        var newHeightMap:[(spotID:Int, height:Int)] = []
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let newHeight:Int = sourceData![10]!["size"]! as Int
            self.waveDataDictionary[spotID]!.spotHeight = newHeight
        })
        sourceTask.resume()
    }
}



























