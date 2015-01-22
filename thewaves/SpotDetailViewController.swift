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

    // this is the label that displays the name of the spot
    @IBOutlet weak var spotNameLabel: UILabel!
    
    // this is the label that displays the current height of the spot
    @IBOutlet weak var spotCurrentHeightLabel: UILabel!
    
    // this is the label that displays the direction of the most significant swell of the spot
    @IBOutlet weak var spotDirectionLabel: UILabel!
    
    // this is the label that displays the period of the most significant swell of the spot
    @IBOutlet weak var spotPeriodLabel: UILabel!
    
    // this is the label that displays the english-language condition of the spot
    @IBOutlet weak var spotConditionLabel: UILabel!
    
    // this is the label that that displays the speed and direction of the wind of the spot
    @IBOutlet weak var spotWindLabel: UILabel!
    
    // this is the label that dispalys the water temperature of the spot
    @IBOutlet weak var spotWaterTempLabel: UILabel!
    
    // this is the label that displays the hour of the tide at a certain time at this spot
    @IBOutlet weak var spotTideTimeLabel: UILabel!
    
    // this is the label that displays the height of the tide at a certain time at this spot
    @IBOutlet weak var spotTideHeightLabel: UILabel!
    
    // this is the label that displays the height of the swell at a certain time at this spot
    @IBOutlet weak var spotHeightChartHeightLabel: UILabel!
    
    // this is the label that displays the hour of the swell at a certain at this spot
    @IBOutlet weak var spotHeightChartTimeLabel: UILabel!
    

    
    
    // called once
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the gesture recognizer that will recognize edge swipes from the left side of the screen to the right
        // to handle returning to the yourSpotsTableViewController
        self.createEdgePanGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // set the background color of the view to be the same background color as that of the main view
        self.view.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
        
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
    // createEdgePanGestureRecognizer does all necessary setup to allow the user to left-to-right edge swipe this view
    // to perform a segue back to the main view. For more detail see handleOnstagePan below
    func createEdgePanGestureRecognizer() {
        // add an edge swipe gesture recognizer to the left edge of the display
        self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
        self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
        self.enterPanGesture.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(self.enterPanGesture)
    }
    
    // handleOnstagePan does nothing but perform a segue back to the main view when the user completes a 
    // left-to-right edge swipe on this view
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        switch (pan.state) {
        case UIGestureRecognizerState.Ended:
            // perform segue back to the main view
            self.performSegueWithIdentifier("unwindFromSpotDetail", sender: self)
            break
        default:
            break
        }
        
    }
    
    // MARK: Create and manage colors, labels, and display
    // setViewLabels sets the name, height, direction, period, condition, water temperature, and wind labels of the view by calling methods
    // of the SpotLibrary class to retrieve stored data for this spot
    func setViewLabels() {
        // get values
        self.spotNameLabel.text = self.spotLibrary.name(selectedSpotID)
        if let waterTemp = self.spotLibrary.waterTemp(selectedSpotID) {
            self.spotWaterTempLabel.text = "\(waterTemp)°"
        }
        else {
            self.spotWaterTempLabel.text = " "
        }
        if let swellHeight = self.spotLibrary.currentHeight(selectedSpotID) {
            self.spotCurrentHeightLabel.text = "\(swellHeight)-\(swellHeight + 1)ft"
        }
        else {
            self.spotCurrentHeightLabel.text = " "
        }
        if let swell = self.spotLibrary.significantSwell(selectedSpotID) {
            self.spotDirectionLabel.text = "\(swell.direction)"
            self.spotPeriodLabel.text = "\(swell.period) SEC"
        }
        else {
            self.spotDirectionLabel.text = " "
            self.spotPeriodLabel.text = " "
        }
        if let swellConditions = self.spotLibrary.currentConditions(selectedSpotID) {
            self.spotConditionLabel.text = "\(swellConditions.uppercaseString)"
        }
        else {
            self.spotConditionLabel.text = " "
        }
        if let wind = self.spotLibrary.wind(selectedSpotID) {
            self.spotWindLabel.text = "\(wind.direction) @ \(wind.speedInMPH) MPH"
        }
        else {
            self.spotWindLabel.text = " "
        }
    }
    
    // set the status bar style to light so that the color of status bar elements is white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: Creating and managing charts
    func createChartsForDetailView() {
        
        // create tideChart object
        tideChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.tideChartView.frame.minY, width: self.view.frame.width, height: self.tideChartView.frame.height), identifier: "tideChart")
        
        // add data to tideChart
        var dataArray:Array<CGFloat> = []
        if let tides = self.spotLibrary.tidesForToday(selectedSpotID) {
            for tide in tides {
                dataArray.append(CGFloat(tide))
            }
        }
        else {
            for (var x = 0; x < 24; x++) {
                dataArray.append(CGFloat(0))
            }
        }
        tideChart.addLine(dataArray)
        
        // create swellChart object
        swellChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.swellChartView.frame.minY, width: self.view.frame.width, height: self.swellChartView.frame.height), identifier: "swellChart")
        
        // add data to swellChart
        dataArray.removeAll(keepCapacity: true)
        if let heights = self.spotLibrary.heightsForToday(selectedSpotID) {
            for height in heights {
                var heightToAdd = CGFloat(Int(height))
                
                if heightToAdd % 2 != 0 {
                    heightToAdd = heightToAdd - 1
                }
                dataArray.append(heightToAdd)
            }
        }
        else {
            for (var x = 0; x < 24; x++) {
                dataArray.append(CGFloat(0))
            }
        }
        
        // map data in swellChart to be even numbers only. Odd numbers get reduced to the closest smaller even number.
        swellChart.addLine(dataArray)
        
        
        // modify tide charts
        for chart in [tideChart, swellChart] {
            chart.animationEnabled = true
            chart.areaUnderLinesVisible = false
            chart.axesColor = UIColor.clearColor()
            chart.gridColor = UIColor.clearColor()
            chart.labelsXVisible = true
            chart.labelsYVisible = false
            chart.axisInset = 24
            chart.dotsBackgroundColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 1)
        }
        
        // add charts to their views
        targetView.addSubview(tideChart)
        targetView.addSubview(swellChart)
        
        // set delegates for charts
        tideChart.delegate = self
        swellChart.delegate = self
        
    }
    
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>, chartIdentifier: String) {
        // get index of touch and set the index to 0 if the touch was made at an index less than 0
        // and 23 if the touch was made at an index larger that 23
        var chartIndexTouched:Int = Int(x)
        if chartIndexTouched < 0 {
            chartIndexTouched = 0
        }
        else if chartIndexTouched > 23 {
            chartIndexTouched = 23
        }
        
        // create strings for the tide value label. The format is different for the tideLabel vs. the swellChart label
        // and those differences are separated here. chartIdentifier tells us which chart was touched, since this viewController
        // is the delegate for two LineChart objects and we must know which chart was touched to update the appropriate chart.
        var heightString:String = ""
        var timeString = "\(graphIndexToTimeString(chartIndexTouched, true))"
        
        if chartIdentifier == "tideChart" {
            heightString = "\(Int(yValues.first!))ft"
        }
        else if chartIdentifier == "swellChart" {
            heightString = "\(Int(yValues.first!))-\(Int(yValues.first!) + 1)ft"
        }
        
        if chartIdentifier == "tideChart" {
            self.spotTideHeightLabel.text = heightString
            self.spotTideTimeLabel.text = timeString
        }
        if chartIdentifier == "swellChart" {
            self.spotHeightChartHeightLabel.text = heightString
            self.spotHeightChartTimeLabel.text = timeString
        }
    }
    
    // didRoateFromInterfaceOrientation redraws views that need to be updated when the user rotates
    // their device from orientation to another.
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.gradient.frame = self.view.bounds
        self.setNeedsStatusBarAppearanceUpdate()
        self.gradient.setNeedsDisplay()
        tideChart.frame = CGRect(x: self.view.frame.minX, y: self.tideChartView.frame.minY, width: self.view.frame.width, height: self.tideChartView.frame.height)
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
