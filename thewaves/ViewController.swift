//
//  ViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/2/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mainTableView: UITableView!
    
    let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/orange-county/")
    var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var sourceData:AnyObject? = nil
    var spotNames:[String] = []
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            self.sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            })
        sourceTask.resume()
        sleep(1)
        let numberInData:Int! = sourceData?.count!
        for var index = 0; index < numberInData; index++ {
            let spotName:String = sourceData![index]!["spot_name"]! as String
            self.spotNames += spotName
        }
        self.spotNames = sorted(self.spotNames, forwards)
        return numberInData
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell = self.mainTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel.text = self.spotNames[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView!, didDeselectRowAtIndexPath indexPath: NSIndexPath!)  {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}

func forwards(s1: String, s2: String) -> Bool
{
    return s1 < s2
}