//
//  DetailViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 12/6/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import SnapKit

// DetailViewController displays detailed forecast information for a surf spot.
class DetailViewController: UIViewController, UIScrollViewDelegate, LineChartDelegate {

    // MARK: - Properties -
    var model:DetailViewModel?
    var selectedSpotID:Int!
    var currentHour:Int!

    let gradient:CAGradientLayer = CAGradientLayer()

    var tideChart:LineChart = LineChart(frame: CGRectZero, identifier: "tideChart")
    var swellChart:LineChart = LineChart(frame: CGRectZero, identifier: "swellChart")
    
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
        else {
            let welcomeView = UIView(frame: CGRectZero)
            welcomeView.backgroundColor = self.view.backgroundColor
            self.view.addSubview(welcomeView)
            welcomeView.snp_makeConstraints { make in
                make.centerY.equalTo(view.snp_centerY)
                make.centerX.equalTo(view.snp_centerX)
                make.height.equalTo(view.snp_height)
                make.width.equalTo(view.snp_width)
            }
            
            let label = UILabel(frame: CGRectZero)
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFontOfSize(24.0, weight: 0.1)
            } else {
                label.font = UIFont.systemFontOfSize(24.0)
                // Fallback on earlier versions
            }
            label.textColor = UIColor.lightGrayColor()
            label.textAlignment = .Center
            label.text = "Tap a spot to view a forecast"
            welcomeView.addSubview(label)
            label.snp_makeConstraints { make in
                make.centerX.equalTo(welcomeView.snp_centerX)
                make.centerY.equalTo(welcomeView.snp_centerY).offset(-100)
                make.height.equalTo(200)
                make.width.equalTo(welcomeView.snp_width)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let _ = model {
            self.tideChart.highlightDataPoints(self.currentHour)
            self.swellChart.highlightDataPoints(self.currentHour)
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        tideChart.snp_makeConstraints { make in
            make.height.equalTo(tideChartView.snp_height)
            make.width.equalTo(tideChartView.snp_width)
            make.centerX.equalTo(tideChartView.snp_centerX)
            make.centerY.equalTo(tideChartView.snp_centerY)
        }
        
        targetView.addSubview(swellChart)
        swellChart.snp_makeConstraints { make in
            make.height.equalTo(swellChartView.snp_height)
            make.width.equalTo(swellChartView.snp_width)
            make.centerX.equalTo(swellChartView.snp_centerX)
            make.centerY.equalTo(swellChartView.snp_centerY)
        }
        
        tideChart.delegate = self
        swellChart.delegate = self
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        tideChart.setNeedsDisplay()
        swellChart.setNeedsDisplay()
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
        let timeString = "\(graphIndexToTimeString(chartIndexTouched, longForm: true))"
        
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

