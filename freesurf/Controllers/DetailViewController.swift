//
//  DetailViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 12/6/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

// DetailViewController displays detailed forecast information for a surf spot.
class DetailViewController: UIViewController, UIScrollViewDelegate, LineChartDelegate {

    // MARK: - Properties -
    var model:DetailViewModel?
    var selectedSpotID:Int!
    var currentHour:Int!
    
    var enterPanGesture: UIScreenEdgePanGestureRecognizer!

    let gradient:CAGradientLayer = CAGradientLayer()

    var tideChart:LineChart = LineChart()
    var swellChart:LineChart = LineChart()
    
    @IBOutlet weak var tideChartView: UIView!
    @IBOutlet weak var swellChartView: UIView!
    @IBOutlet weak var targetView: UIView!

    @IBOutlet weak var spotWaterTempLabel: UILabel!
    @IBOutlet weak var spotCurrentHeightLabel: UILabel!
    @IBOutlet weak var spotDirectionLabel: UILabel!
    @IBOutlet weak var spotPeriodLabel: UILabel!
    @IBOutlet weak var spotConditionLabel: UILabel!
    @IBOutlet weak var spotWindLabel: UILabel!
    
    @IBOutlet weak var spotTideTimeLabel: UILabel!
    @IBOutlet weak var spotTideHeightLabel: UILabel!
    @IBOutlet weak var spotHeightChartHeightLabel: UILabel!
    @IBOutlet weak var spotHeightChartTimeLabel: UILabel!
    
    // MARK: - View Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
//        self.createEdgePanGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        
        if let model = model {
            self.setLabels(model)
            self.setCharts(model)
            
            self.tideChart.simulateTouchAtIndex(self.currentHour)
            self.swellChart.simulateTouchAtIndex(self.currentHour)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let model = model {
            self.tideChart.highlightDataPoints(self.currentHour)
            self.swellChart.highlightDataPoints(self.currentHour)
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: - Interface Actions -
    func createEdgePanGestureRecognizer() {
        self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
        
        self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
        self.enterPanGesture.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(self.enterPanGesture)
    }

    func handleOnstagePan(pan: UIPanGestureRecognizer){
        switch (pan.state) {
        case UIGestureRecognizerState.Ended:
            self.performSegueWithIdentifier("unwindFromSpotDetail", sender: self)
            break
        default:
            break
        }
        
    }
    
    // MARK: - Methods -
    func setLabels(model:DetailViewModel) {
        self.title = model.name
        self.spotWaterTempLabel.text = model.temp
        self.spotCurrentHeightLabel.text = model.height
        self.spotDirectionLabel.text = model.swellDirection
        self.spotPeriodLabel.text = model.swellPeriod
        self.spotConditionLabel.text = model.condition
        self.spotWindLabel.text = model.wind
    }

    func setCharts(model:DetailViewModel) {
        
        tideChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.tideChartView.frame.minY, width: self.view.frame.width, height: self.tideChartView.frame.height), identifier: "tideChart")
        swellChart = LineChart(frame: CGRect(x: self.view.frame.minX, y: self.swellChartView.frame.minY, width: self.view.frame.width, height: self.swellChartView.frame.height), identifier: "swellChart")
        
        tideChart.addLine(model.tides)
        swellChart.addLine(model.heights)
        
        for chart in [tideChart, swellChart] {
            chart.animationEnabled = false
            chart.areaUnderLinesVisible = false
            chart.axesColor = UIColor.clearColor()
            chart.gridColor = UIColor.clearColor()
            chart.labelsXVisible = true
            chart.labelsYVisible = false
            chart.axisInset = 24
            chart.dotsBackgroundColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 1)
        }
        
        targetView.addSubview(tideChart)
        targetView.addSubview(swellChart)
        
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
        
        var heightString:String = ""
        var timeString = "\(graphIndexToTimeString(chartIndexTouched, true))"
        
        heightString = "\(Int(yValues.first!))ft"
        
        if chartIdentifier == "tideChart" {
            self.spotTideHeightLabel.text = heightString
            self.spotTideTimeLabel.text = timeString
        }
        if chartIdentifier == "swellChart" {
            self.spotHeightChartHeightLabel.text = heightString
            self.spotHeightChartTimeLabel.text = timeString
        }
    }
    

}

