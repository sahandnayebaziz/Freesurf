//
//  ViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/2/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDelegate {
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/orange-county/")
    var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var sourceData:AnyObject?
    
    @IBAction func clearData(sender: AnyObject) {
        textArea.text = "Cleared."
    }
    @IBAction func loadData(sender: AnyObject) {
        if !(textArea.text == "Cleared.") || !(textArea.text == "This is where the waves data will load once received.") {
            let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
                self.sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                })
            sourceTask.resume()
            textArea.text = "\(self.sourceData)"
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

