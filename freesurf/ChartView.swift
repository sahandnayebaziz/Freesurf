//
//  ChartView.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/20/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit

enum ChartViewType {
    case tides, swell
    
    func getText() -> String {
        switch self {
        case .tides:
            return "Tide"
        case .swell:
            return "Heights"
        }
    }
}

class ChartView: UIView, SpotDataDelegate, LineChartDelegate {
    
    let chart = LineChart(frame: CGRect.zero)
    let type: ChartViewType
    
    let typeLabel = UILabel()
    let valueLabel = UILabel()
    let timeLabel = UILabel()
    
    init(type: ChartViewType) {
        self.type = type
        super.init(frame: CGRect.zero)
        
        typeLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        typeLabel.textColor = Colors.blue
        addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
        }
        typeLabel.text = type.getText()
        
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        valueLabel.textAlignment = .right
        valueLabel.textColor = UIColor.white
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.top.equalTo(0)
        }
        
        timeLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        timeLabel.textColor = Colors.blue
        timeLabel.textAlignment = .right
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
        }
        
        chart.axesVisible = false
        chart.delegate = self
        chart.animationEnabled = false
        chart.areaUnderLinesVisible = false
        chart.axesColor = UIColor.clear
        chart.gridColor = UIColor.clear
        chart.labelsXVisible = false
        chart.labelsYVisible = false
        chart.axisInset = 24
        chart.dotsBackgroundColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 1)
    }
    
    func did(updateSpot spot: SpotData) {
        if type == .swell {
            guard let heights = spot.heights else {
                return
            }
            
            set(chartWithValues: heights.map({ CGFloat($0) }))
        }
    }
    
    func did(updateCounty county: CountyData) {
        if type == .tides {
            guard let tides = county.tides else {
                return
            }
            
            set(chartWithValues: tides.map({ CGFloat($0) }))
        }
    }
    
    private func set(chartWithValues values: [CGFloat]) {
        chart.removeFromSuperview()
        chart.clear()
        chart.addLine(values)
        addSubview(chart)
        chart.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom)
            make.bottom.equalTo(self)
            make.width.equalTo(self)
            make.centerX.equalTo(self)
        }
        chart.highlightDataPoints(Date().hour())
        chart.simulateTouchAtIndex(Date().hour())
    }
    
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>, chartIdentifier: String) {
        let chartIndexTouched = x < 0 ? 0 : x > 23 ? 23 : Int(x)
        
        timeLabel.text = graphIndexToTimeString(chartIndexTouched, longForm: true)
        valueLabel.text = "\(Int(yValues.first!))ft"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
