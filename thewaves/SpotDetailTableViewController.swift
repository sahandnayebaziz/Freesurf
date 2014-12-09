//
//  SpotDetailTableViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 12/6/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class SpotDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    var spotLibrary:SpotLibrary!
    var selectedSpotID:Int!
    var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    var currentHour:Int = NSDate().hour()
    let gradient:CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
        self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
        self.enterPanGesture.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(self.enterPanGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        self.setBackgroundColor(self.spotLibrary.heightAtHour(selectedSpotID, hour: currentHour)!)
        self.setLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.Cancelled:
            break
            
        case UIGestureRecognizerState.Ended:
            // trigger the start of the transition
            self.performSegueWithIdentifier("unwindFromSpotDetail", sender: self)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            break
        }
    }
    
    func setBackgroundColor(height:Int) {
        var colorTop:CGColorRef;
        var colorBottom:CGColorRef;
        if height <= 2 {
            colorTop = UIColor(red: 70/255.0, green: 104/255.0, blue: 130/255.0, alpha: 1.0).CGColor!
            colorBottom = UIColor(red: 58/255.0, green: 100/255.0, blue: 131/255.0, alpha: 1.0).CGColor!
        }
        else if height <= 4 {
            colorTop = UIColor(red: 95/255.0, green: 146/255.0, blue: 185/255.0, alpha: 1.0).CGColor!
            colorBottom = UIColor(red: 77/255.0, green: 139/255.0, blue: 186/255.0, alpha: 1.0).CGColor!
        }
        else {
            colorTop = UIColor(red: 120/255.0, green: 188/255.0, blue: 240/255.0, alpha: 1.0).CGColor!
            colorBottom = UIColor(red: 97/255.0, green: 179/255.0, blue: 242/255.0, alpha: 1.0).CGColor!
        }
        gradient.colors = [colorTop, colorBottom]
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func setLabels() {
        let heights = self.spotLibrary.heightsForNext24Hours(selectedSpotID, hour: 0)
        let periods = self.spotLibrary.periodsForNext24Hours(selectedSpotID, hour: 0)
        let directions = self.spotLibrary.directionsForNext24Hours(selectedSpotID, hour: 0)
        
        var indexOfMostSignifcantSwellInSwellData:Int = 0
        var heightOfMostSignificantSwellInSwellData:Int = -1
        
        for (var possibleMaxHeightIndex:Int = 0; possibleMaxHeightIndex < heights!.count; possibleMaxHeightIndex++) {
            
            if heights![possibleMaxHeightIndex] > heightOfMostSignificantSwellInSwellData {
                heightOfMostSignificantSwellInSwellData = heights![possibleMaxHeightIndex]
                indexOfMostSignifcantSwellInSwellData = possibleMaxHeightIndex
            }
        }
        
        let periodOfMostSignificantSwellInSwellData:Int = periods![indexOfMostSignifcantSwellInSwellData]
        let directionOfMostSignificantSwellInSwellData:String = directions![indexOfMostSignifcantSwellInSwellData]
        
        
        self.nameLabel.text = self.spotLibrary.name(selectedSpotID)
        self.heightLabel.text = "\(self.spotLibrary.heightAtHour(selectedSpotID, hour: currentHour)!)ft \(periodOfMostSignificantSwellInSwellData)s \(directionOfMostSignificantSwellInSwellData)"
        self.weekdayLabel.text = NSDate().weekdayToString()
        self.tempLabel.text = "\(self.spotLibrary.waterTemp(selectedSpotID)!)°"
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
