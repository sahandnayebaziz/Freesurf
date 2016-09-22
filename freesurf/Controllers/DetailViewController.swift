//
//  DetailViewController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 12/6/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import AFDateHelper
import SnapKit

class DetailViewController: UIViewController, UIScrollViewDelegate, SpotDataDelegate {
    
    var representedSpot: SpotData? = nil
    let welcomeLabel = UILabel()
    
    var scrollView: UIScrollView? = nil
    let stackView = UIStackView()

    let heightAndTemperatureView = HeightAndTemperatureView()
    let conditionsView = ConditionsView()
    let tideChart = ChartView(type: .tides)
    let heightChart = ChartView(type: .swell)
    
    init(forSpot spot: SpotData?) {
        representedSpot = spot
        super.init(nibName: nil, bundle: nil)
        
        if spot == nil {
            setForNoSpot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for chartView in [tideChart, heightChart] {
            if !chartView.chart.dataStore.isEmpty {
                chartView.chart.highlightDataPoints(Date().hour())
//                chartView.chart.simulateTouchAtIndex(Date().hour())
            }
        }
    }
    
    func did(updateSpot spot: SpotData) {
        guard let representedSpot = representedSpot else {
            return
        }
        
        guard representedSpot.id == spot.id else {
            return
        }
        
        setForSpot()
        title = spot.name
        
        for delegate in [heightAndTemperatureView, conditionsView, tideChart, heightChart] as [SpotDataDelegate] {
            delegate.did(updateSpot: spot)
        }
    }
    
    func did(updateCounty county: CountyData) {
        guard let representedSpot = representedSpot else {
            return
        }
        
        guard representedSpot.county == county.name else {
            return
        }
        
        for delegate in [heightAndTemperatureView, conditionsView, tideChart, heightChart] as [SpotDataDelegate] {
            delegate.did(updateCounty: county)
        }
    }
    
    func setForNoSpot() {
        title = ""
        welcomeLabel.text = "Tap a spot to view a forecast"
        welcomeLabel.textAlignment = .center
        welcomeLabel.textColor = UIColor.lightText
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        
        scrollView?.removeFromSuperview()
    }
    
    private func setForSpot() {
        guard scrollView == nil else {
            return
        }
        
        welcomeLabel.removeFromSuperview()
        
        self.scrollView = UIScrollView()
        guard let scrollView = scrollView else {
            return
        }
        
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
        
        let spacer = UIView()
        spacer.snp.makeConstraints { make in
            make.height.equalTo(8)
        }
        stackView.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(heightAndTemperatureView)
        heightAndTemperatureView.snp.makeConstraints { make in
            make.width.equalTo(stackView).offset(-40)
        }
        
        stackView.addArrangedSubview(conditionsView)
        conditionsView.snp.makeConstraints { make in
            make.width.equalTo(stackView).offset(-40)
            make.height.greaterThanOrEqualTo(100)
        }
        
        stackView.addArrangedSubview(tideChart)
        tideChart.snp.makeConstraints { make in
            make.height.equalTo(220)
            make.width.equalTo(stackView).offset(-40)
        }
        
        stackView.addArrangedSubview(heightChart)
        heightChart.snp.makeConstraints { make in
            make.height.equalTo(220)
            make.width.equalTo(stackView).offset(-40)
        }
    }

    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tideChart.chart.setNeedsDisplay()
        heightChart.chart.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

