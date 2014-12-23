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
    
    // currentHour is an integer representing the current hour of the day in 24-hour time
    // :: midnight is "0" and 11PM is "23"
    var currentHour:Int = NSDate().hour()
    
    // this is the gesture recognizer that will allow edge swipes to be detected
    var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    
    // this gradient layer will be used to give the entire view a background color similar to the one of the cell for this spot
    // in YourSpotsTableView
    let gradient:CAGradientLayer = CAGradientLayer()
    
    // the tideChart object
    var tideChart:LineChart = LineChart()
    
    // the swellChart object
    var swellChart:LineChart = LineChart()
    
    // this view is the view that tideChart will be added to
    @IBOutlet weak var tideChartView: UIView!
    
    // this view is the view that swellChart will be added to
    @IBOutlet weak var swellChartView: UIView!
    
    // this is the view the charts will be added to
    @IBOutlet weak var targetView: UIView!

    // labels need to be documented
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var spotCurrentHeightLabel: UILabel!
    @IBOutlet weak var spotConditionsLabel: UILabel!
    @IBOutlet weak var spotDirectionAndPeriodLabel: UILabel!
    @IBOutlet weak var spotTideHeightAtHour: UILabel!
    @IBOutlet weak var spotSwellHeightAtHour: UILabel!

    // called once
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the gesture recognizer that will recognize edge swipes from the left side of the screen to the right
        // to handle returning to the yourSpotsTableViewController
        self.createEdgePanGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // set the background color of the view based on the size of this spot's swell height
        self.setBackgroundColor(self.spotLibrary.currentHeight(selectedSpotID)!)
        
        // set the labels
        self.setViewLabels()
        
        // create the tide chart
        self.createChartsForDetailView()
        
        // simulate touches for the current hour of both charts
        // this will call the charts delegate method and set the labels for each chart before the user views the charts
        self.tideChart.simulateTouchAtIndex(self.currentHour)
        self.swellChart.simulateTouchAtIndex(self.currentHour)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // highlight the data points for the current hour on both charts
        self.tideChart.highlightDataPoints(self.currentHour)
        self.swellChart.highlightDataPoints(self.currentHour)
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
    func setViewLabels() {
        // get values
        let swellHeight = self.spotLibrary.currentHeight(selectedSpotID)!
        let swellConditions = self.spotLibrary.currentConditions(selectedSpotID)!
        let swell = self.spotLibrary.significantSwell(selectedSpotID)!

        // set labels
        self.spotNameLabel.text = self.spotLibrary.name(selectedSpotID)
        self.spotCurrentHeightLabel.text = "\(swellHeight)ft"
        self.spotConditionsLabel.text = "\(swellConditions.lowercaseString) conditions"
        self.spotDirectionAndPeriodLabel.text = "\(swell.direction) @ \(swell.period)s"
        
    }
    
    func setBackgroundColor(height:Int) {
        // set the background color of this view to be a dark, near-black gray
        self.view.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: Creating and managing charts
    func createChartsForDetailView() {
        
        // create tideChart object
        tideChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.tideChartView.frame.minY, width: self.view.frame.width, height: self.tideChartView.frame.height), identifier: "tideChart")
        
        // add data to tideChart
        var dataArray:Array<CGFloat> = []
        var tides = self.spotLibrary.tidesForToday(selectedSpotID)!
        for tide in tides {
            dataArray.append(CGFloat(tide))
        }
        tideChart.addLine(dataArray)
        
        // create swellChart object
        swellChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.swellChartView.frame.minY, width: self.view.frame.width, height: self.swellChartView.frame.height), identifier: "swellChart")
        
        // add data to swellChart
        dataArray.removeAll(keepCapacity: true)
        var heights = self.spotLibrary.heightsForToday(selectedSpotID)!
        
        // map data in swellChart to be even numbers only. Odd numbers get reduced to the closest smaller even number.
        for height in heights {
            var heightToAdd = CGFloat(Int(height))
            
            if heightToAdd % 2 != 0 {
                heightToAdd = heightToAdd - 1
            }
            dataArray.append(heightToAdd)
        }
        swellChart.addLine(dataArray)
        
        
        // modify tide charts
        let blueColorUsed:UIColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 1)
        
        for chart in [tideChart, swellChart] {
            chart.animationEnabled = true
            chart.areaUnderLinesVisible = false
            chart.axesColor = UIColor.clearColor()
            chart.gridColor = UIColor.clearColor()
            chart.labelsXVisible = false
            chart.axisInset = 24
            chart.dotsBackgroundColor = blueColorUsed
        }
        
        // add charts to their views
        targetView.addSubview(tideChart)
        targetView.addSubview(swellChart)
        
        // set delegates for charts
        tideChart.delegate = self
        swellChart.delegate = self
        
    }
    
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>, chartIdentifier: String) {
        // get index of touch
        var chartIndexTouched = x
        if chartIndexTouched < 0 {
            chartIndexTouched = 0
        }
        else if chartIndexTouched > 23 {
            chartIndexTouched = 23
        }
        
        var heightString:String = ""
        if chartIdentifier == "tideChart" {
            // set to label
            heightString = "\(Int(yValues.first!))ft"
        }
        else if chartIdentifier == "swellChart" {
            // set to label
            heightString = "\(Int(yValues.first!))-\(Int(yValues.first!) + 1)ft"
        }
        
        var timeString = "@ \(graphIndexToTimeString(chartIndexTouched)) Today"
        var completeString = "\(heightString) \(timeString)"
        var locationOfTimeString:Int = countElements(heightString) + 1
        var attributedComplete:NSMutableAttributedString = NSMutableAttributedString(string: completeString)
        attributedComplete.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(locationOfTimeString, countElements(timeString)))
        
        if chartIdentifier == "tideChart" {
            self.spotTideHeightAtHour.attributedText = attributedComplete
        }
        else if chartIdentifier == "swellChart" {
            self.spotSwellHeightAtHour.attributedText = attributedComplete
        }
        
        //        uncomment to highlight the time in the timeString to be the color blue
        //        if (Int(chartIndexTouched) == self.currentHour) {
        //            var color:UIColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 1)
        //            attributedComplete.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(locationOfTimeString, countElements(timeString)))
        //        }
    }
    
    // MARK: View delegate methods
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.gradient.frame = self.view.bounds
        self.setNeedsStatusBarAppearanceUpdate()
        self.gradient.setNeedsDisplay()
        tideChart.frame = CGRect(x: self.view.frame.minX, y: self.tideChartView.frame.minY, width: self.view.frame.width, height: self.tideChartView.frame.height)
        tideChart.setNeedsDisplay()
    }
    
    func graphIndexToTimeString(graphIndex: CGFloat) -> String {
        var timeStringIn12HourTime = ""
        var hourOfDay = Int(graphIndex)
        if hourOfDay < 12 {
            if hourOfDay == 0 {
                timeStringIn12HourTime = "12AM"
            }
            else {
                timeStringIn12HourTime = "\(hourOfDay)AM"
            }
        }
        else if hourOfDay >= 12 {
            if hourOfDay == 23 {
                timeStringIn12HourTime = "11PM"
            }
            else {
                hourOfDay = hourOfDay - 12
                if hourOfDay == 0 {
                    timeStringIn12HourTime = "12PM"
                }
                else {
                    timeStringIn12HourTime = "\(hourOfDay)PM"
                }
            }
        }
        
        return "\(timeStringIn12HourTime)"
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
