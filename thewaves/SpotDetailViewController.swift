//
//  SpotDetailViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 12/6/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

// SpotDetailViewController displays detailed forecast information for a surf spot.
// :: the user enters this view when they select a cell in the YourSpotsTableViewController
class SpotDetailViewController: UIViewController, UIScrollViewDelegate, LineChartDelegate {
    
    // spotLibrary is the SpotLibrary object containing spot and county data passed to this view controller from YourSpotsTableView
    var spotLibrary:SpotLibrary!
    
    // this is the id of the spot selected by the user
    var selectedSpotID:Int!
    
    // this is the gesture recognizer that will allow edge swipes to be detected
    var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    
    // this gradient layer will be used to give the entire view a background color similar to the one of the cell for this spot 
    // in YourSpotsTableView
    let gradient:CAGradientLayer = CAGradientLayer()
    
    // the tideChart object
    var tideChart:LineChart = LineChart()
    
    // this view is the view that gives tideChart it's size
    @IBOutlet weak var copyView: UIView!
    
    // this view is the view that tideChart will be added to
    @IBOutlet weak var targetView: UIView!
    
    // these labels display the tide that is selected by the user on the tide chart
    @IBOutlet weak var tideChartTimeLabel: UILabel!
    @IBOutlet weak var tideChartHeightLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createEdgePanGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // set the background color of the view based on the size of this spot's swell height
        self.setBackgroundColor(self.spotLibrary.currentHeight(selectedSpotID)!)
        
        // create the tide chart
        self.createChartsForDetailView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Create and manage gesture recognizers
    func createEdgePanGestureRecognizer() {
        // add an edge swipe gesture recognizer to the left edge of the display
        self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
        self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
        self.enterPanGesture.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(self.enterPanGesture)
    }
    
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
    
    // MARK: Create and manage colors, labels, and display
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
    // MARK: Creating and managing charts
    func createChartsForDetailView() {
        
        // set the frame for the chart
        tideChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.copyView.frame.minY, width: self.view.frame.width, height: self.copyView.frame.height))
        
        // add data to tide chart
        var dataArray:Array<CGFloat> = []
        var tides = self.spotLibrary.next24Tides(selectedSpotID)!
        
        for tide in tides {
            dataArray.append(CGFloat(tide))
        }
        
        tideChart.addLine(dataArray)
        
        // modify tide chart
        let lightGray:UIColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 0.13)
        
        tideChart.animationEnabled = false
        tideChart.areaUnderLinesVisible = true
        tideChart.axesColor = lightGray
        tideChart.gridColor = lightGray
        
        // add tideChart to the view
        targetView.addSubview(tideChart)
        
        // add self as delegate
        tideChart.delegate = self

    }
    
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        tideChartHeightLabel.text = "\(Int(yValues.first!))ft"
        
        var timeStringIn12HourTime:String = ""
        var hourOfDay = Int(x) + self.spotLibrary.currentHour
        if hourOfDay >= 24 {
            hourOfDay = hourOfDay - 24
        }
        if hourOfDay < 12 {
            if hourOfDay == 0 {
                timeStringIn12HourTime = "12AM"
            }
            else {
                timeStringIn12HourTime = "\(hourOfDay)AM"
            }
        }
        else if hourOfDay >= 12 {
            hourOfDay = hourOfDay - 12
            if hourOfDay == 0 {
                timeStringIn12HourTime = "12PM"
            }
            else {
                timeStringIn12HourTime = "\(hourOfDay)PM"
            }
        }
        
        tideChartTimeLabel.text = timeStringIn12HourTime
    }

    // MARK: View delegate methods
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.gradient.frame = self.view.bounds
        self.setNeedsStatusBarAppearanceUpdate()
        self.gradient.setNeedsDisplay()
        tideChart.frame = CGRect(x: self.view.frame.minX, y: self.copyView.frame.minY, width: self.view.frame.width, height: self.copyView.frame.height)
        tideChart.setNeedsDisplay()
    }
}



































































































//    // MARK: - Table view data source
//
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }
//
//
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
//
//        // Configure the cell...
//
//        return cell
//    }
//
//
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return NO if you do not want the specified item to be editable.
//        return true
//    }
//    */
//
//    /*
//    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
//    */
//
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//
//    }
//    */
//
//    /*
//    // Override to support conditional rearranging of the table view.
//    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return NO if you do not want the item to be re-orderable.
//        return true
//    }
//    */
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//    }
//    */
