//
//  DetailViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 12/6/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController, UIScrollViewDelegate, SpotDataDelegate, LineChartDelegate {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let heightAndTemperatureView = HeightAndTemperatureView()
    let conditionsView = ConditionsView()
    

    var tideChart:LineChart = LineChart(frame: CGRect.zero, identifier: "tideChart")
    var swellChart:LineChart = LineChart(frame: CGRect.zero, identifier: "swellChart")
    
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
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(view)
            make.width.equalTo(view)
        }
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView)
            make.bottom.equalTo(scrollView)
            make.right.equalTo(scrollView)
            make.left.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.centerX.equalTo(scrollView)
        }
        
        stackView.addArrangedSubview(heightAndTemperatureView)
        heightAndTemperatureView.snp.makeConstraints { make in
            make.width.equalTo(stackView).offset(-40)
        }
        
        stackView.addArrangedSubview(conditionsView)
        conditionsView.snp.makeConstraints { make in
            make.width.equalTo(stackView).offset(-40)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
//        if let model = model {
//            self.setLabels(model)
//            self.setCharts(model)
//            
//            self.tideChart.simulateTouchAtIndex(self.currentHour)
//            self.swellChart.simulateTouchAtIndex(self.currentHour)
//        }
//            let welcomeView = UIView(frame: CGRect.zero)
//            welcomeView.backgroundColor = self.view.backgroundColor
//            self.view.addSubview(welcomeView)
//            welcomeView.snp.makeConstraints { make in
//                make.centerY.equalTo(view.snp.centerY)
//                make.centerX.equalTo(view.snp.centerX)
//                make.height.equalTo(view.snp.height)
//                make.width.equalTo(view.snp.width)
//            }
//            
//            let label = UILabel(frame: CGRect.zero)
//            label.font = UIFont.systemFont(ofSize: 24.0, weight: 0.1)
//            label.textColor = UIColor.lightGray
//            label.textAlignment = .center
//            label.text = "Tap a spot to view a forecast"
//            welcomeView.addSubview(label)
//            label.snp.makeConstraints { make in
//                make.centerX.equalTo(welcomeView.snp.centerX)
//                make.centerY.equalTo(welcomeView.snp.centerY).offset(-100)
//                make.height.equalTo(200)
//                make.width.equalTo(welcomeView.snp.width)
//            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if let _ = model {
//            self.tideChart.highlightDataPoints(self.currentHour)
//            self.swellChart.highlightDataPoints(self.currentHour)
//        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func did(updateSpot spot: SpotData) {
        title = spot.name
        
        for delegate in [heightAndTemperatureView, conditionsView] as [SpotDataDelegate] {
            delegate.did(updateSpot: spot)
        }
    }
    
    func did(updateCounty county: CountyData) {
        for delegate in [heightAndTemperatureView, conditionsView] as [SpotDataDelegate] {
            delegate.did(updateCounty: county)
        }
//        spotWaterTempLabel.text = county.waterTemperatureString
//        spotDirectionLabel.text = county.significantSwell?.direction
//        spotPeriodLabel.text = county.periodString
//        spotWindLabel.text = county.windString
    }

//    func setCharts(_ model:DetailViewModel) {
//
//        tideChart.addLine(model.tides)
//        swellChart.addLine(model.heights)
//        
//        for chart in [tideChart, swellChart] {
//            chart.animationEnabled = false
//            chart.areaUnderLinesVisible = false
//            chart.axesColor = UIColor.clear
//            chart.gridColor = UIColor.clear
//            chart.labelsXVisible = true
//            chart.labelsYVisible = false
//            chart.axisInset = 24
//            chart.dotsBackgroundColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 1)
//        }
//        
//        targetView.addSubview(tideChart)
//        tideChart.snp.makeConstraints { make in
//            make.height.equalTo(tideChartView.snp.height)
//            make.width.equalTo(tideChartView.snp.width)
//            make.centerX.equalTo(tideChartView.snp.centerX)
//            make.centerY.equalTo(tideChartView.snp.centerY)
//        }
//        
//        targetView.addSubview(swellChart)
//        swellChart.snp.makeConstraints { make in
//            make.height.equalTo(swellChartView.snp.height)
//            make.width.equalTo(swellChartView.snp.width)
//            make.centerX.equalTo(swellChartView.snp.centerX)
//            make.centerY.equalTo(swellChartView.snp.centerY)
//        }
//        
//        tideChart.delegate = self
//        swellChart.delegate = self
//        
//    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tideChart.setNeedsDisplay()
        swellChart.setNeedsDisplay()
    }
    
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>, chartIdentifier: String) {
        
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

