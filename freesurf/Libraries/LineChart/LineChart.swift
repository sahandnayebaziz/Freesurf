//
//  LineChart.swift
//  Created by Mirco Zeiss
//
//  Released under the MIT License at github.com/zemirco/swift-linechart
//
//  Modified by Sahand Nayebaziz for deployment in this application. Changes have been documented in this file.

import UIKit
import QuartzCore

// make Arrays substractable
func - (left: Array<CGFloat>, right: Array<CGFloat>) -> Array<CGFloat> {
    var result: Array<CGFloat> = []
    for index in 0..<left.count {
        let difference = left[index] - right[index]
        result.append(difference)
    }
    return result
}

// delegate method
@objc protocol LineChartDelegate {
    
    // modified to require a chartIdentifier to be sent to the delegate when this is called. This was added
    // when I created two LineChart objects in with the same viewController as delegate and could no think
    // of no other way to identify which LineChart object the touches were coming from.
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>, chartIdentifier: String)
}

// LineChart class
class LineChart: UIControl {
    
    // chartIdentifier is a string that can be used to name an instance of LineChart object and later identify
    // one instance of a LineChart object from another when one viewController is the delegate for two or more
    // LineChart objects.
    var chartIdentifier:String = ""
    
    // default configuration
    var gridVisible = true
    var axesVisible = true
    var dotsVisible = true
    var labelsXVisible = false
    var labelsYVisible = false
    var areaUnderLinesVisible = false
    var numberOfGridLinesX: CGFloat = 10
    var numberOfGridLinesY: CGFloat = 10
    var animationEnabled = true
    var animationDuration: CFTimeInterval = 1
    var dotsBackgroundColor = UIColor.white
    var gridColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    var axesColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1)
    var positiveAreaColor = UIColor(red: 246/255.0, green: 153/255.0, blue: 136/255.0, alpha: 1)
    var negativeAreaColor = UIColor(red: 114/255.0, green: 213/255.0, blue: 114/255.0, alpha: 1)
    
    // not yet sure how this is used
    var areaBetweenLines = [-1, -1]
    
    // sizes
    var lineWidth: CGFloat = 2
    var outerRadius: CGFloat = 12
    var innerRadius: CGFloat = 8
    var outerRadiusHighlighted: CGFloat = 12
    var innerRadiusHighlighted: CGFloat = 8
    var axisInset: CGFloat = 10
    
    // values calculated on init
    var drawingHeight: CGFloat = 0
    var drawingWidth: CGFloat = 0
    
    var delegate: LineChartDelegate?
    
    // data stores
    var dataStore: Array<Array<CGFloat>> = []
    var dotsDataStore: Array<Array<DotCALayer>> = []
    var lineLayerStore: Array<CAShapeLayer> = []
    var lineHighlightLayerStore: Array<CAShapeLayer> = []
    var color: UIColor = UIColorFromHex(0x1f77b4)
    
    var removeAll: Bool = false
    
    // necessary init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    // necessary init
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    // necessary init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // intitialization added to take indentifer to be used as chartIdentifier
    init(frame: CGRect, identifier: String) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.chartIdentifier = identifier
    }
    
    
    override func draw(_ rect: CGRect) {
        
        if removeAll {
            let context = UIGraphicsGetCurrentContext()
            context?.clear(rect)
            return
        }
        
        self.drawingHeight = self.bounds.height - (2 * axisInset)
        self.drawingWidth = self.bounds.width - (2 * axisInset)
        
        // remove all labels
        for view: AnyObject in self.subviews {
            view.removeFromSuperview()
        }
        
        // remove all lines on device rotation
        for lineLayer in lineLayerStore {
            lineLayer.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()
        
        // remove all dots on device rotation
        for dotsData in dotsDataStore {
            for dot in dotsData {
                dot.removeFromSuperlayer()
            }
        }
        dotsDataStore.removeAll()
        
        // draw grid
        if gridVisible { drawGrid() }
        
        // draw axes
        if axesVisible { drawAxes() }
        
        // draw labels
        if labelsXVisible { drawXLabels() }
        if labelsYVisible { drawYLabels() }
        
        // draw filled area between charts
        if areaBetweenLines[0] > -1 && areaBetweenLines[1] > -1 {
            drawAreaBetweenLineCharts()
        }
        
        // draw lines
        for (lineIndex, lineData) in dataStore.enumerated() {
            let scaledDataXAxis = scaleDataXAxis(lineData)
            let scaledDataYAxis = scaleDataYAxis(lineData)
            drawLine(scaledDataXAxis, yAxis: scaledDataYAxis, lineIndex: lineIndex)
            
            // draw dots
            if dotsVisible { drawDataDots(scaledDataXAxis, yAxis: scaledDataYAxis, lineIndex: lineIndex) }
            
            // draw area under line chart
            if areaUnderLinesVisible { drawAreaBeneathLineChart(scaledDataXAxis, yAxis: scaledDataYAxis, lineIndex: lineIndex) }
            
        }
        
    }
    
    /**
    * Lighten color.
    */
    func lightenUIColor(_ color: UIColor) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 1.5, alpha: a)
    }
    
    
    
    /**
    * Get y value for given x value. Or return zero or maximum value.
    */
    func getYValuesForXValue(_ x: Int) -> Array<CGFloat> {
        var result: Array<CGFloat> = []
        for lineData in dataStore {
            if x < 0 {
                result.append(lineData[0])
            } else if x > lineData.count - 1 {
                result.append(lineData[lineData.count - 1])
            } else {
                result.append(lineData[x])
            }
        }
        return result
    }
    
    
    
    /**
    * Handle touch events.
    */
    func handleTouchEvents(_ touches: NSSet!, event: UIEvent!) {
        if (self.dataStore.isEmpty) { return }
        let point: AnyObject! = touches.anyObject() as AnyObject!
        let xValue = point.location(in: self).x
        let closestXValueIndex = findClosestXValueInData(xValue)
        let yValues: Array<CGFloat> = getYValuesForXValue(closestXValueIndex)
        highlightDataPoints(closestXValueIndex)
//        drawWordLine(xValue)
        drawWordLine(closestXValueIndex)
        delegate?.didSelectDataPoint(CGFloat(closestXValueIndex), yValues: yValues, chartIdentifier: self.chartIdentifier)
    }
    
    // touchesBegan and touchesMoved are called if the user begins to or continues to touch
    // a LineChart object
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeWordLine()
        handleTouchEvents(touches as NSSet!, event: event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeWordLine()
        handleTouchEvents(touches as NSSet!, event: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeWordLine()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        removeWordLine()
    }
    
    // simulateTouchAtIndex takes an index and calls the delegate's didSelectDataPoint function at the given index
    // to simulate a touch at a given index on a LineChart object.
    func simulateTouchAtIndex(_ index: Int) {
        let yValues: Array<CGFloat> = getYValuesForXValue(index)
        highlightDataPoints(index)
        delegate?.didSelectDataPoint(CGFloat(index), yValues: yValues, chartIdentifier: self.chartIdentifier)
    }

    /**
    * Find closest value on x axis.
    */
    func findClosestXValueInData(_ xValue: CGFloat) -> Int {
        var scaledDataXAxis = scaleDataXAxis(dataStore[0])
        let difference = scaledDataXAxis[1] - scaledDataXAxis[0]
        let dividend = (xValue - axisInset) / difference
        let roundedDividend = Int(round(Double(dividend)))
        return roundedDividend
    }
    
    /**
    * Highlight data points at index.
    */
    func highlightDataPoints(_ index: Int) {
        for (_, dotsData) in dotsDataStore.enumerated() {
            // make all dots white again
            for dot in dotsData {
                if dot != dotsData[Date().hour()] {
                    dot.backgroundColor = dotsBackgroundColor.cgColor
                }
                else {
                    dot.backgroundColor = color.cgColor
                }
            }
            // highlight current data point
            var dot: DotCALayer
            if index < 0 {
                dot = dotsData[0]
            } else if index > dotsData.count - 1 {
                dot = dotsData[dotsData.count - 1]
            } else {
                dot = dotsData[index]
            }

            dot.backgroundColor = UIColor.white.cgColor
        }
    }
    
    
    
    /**
    * Draw small dot at every data point.
    */
    func drawDataDots(_ xAxis: Array<CGFloat>, yAxis: Array<CGFloat>, lineIndex: Int) {
        var dots: Array<DotCALayer> = []
        for index in 0..<xAxis.count {
            let xValue = xAxis[index] + axisInset - outerRadius/2
            let yValue = self.bounds.height - yAxis[index] - axisInset - outerRadius/2
            
            // draw custom layer with another layer in the center
            let dotLayer = DotCALayer()
            dotLayer.dotInnerColor = color
            dotLayer.innerRadius = innerRadius
            dotLayer.backgroundColor = dotsBackgroundColor.cgColor
            dotLayer.cornerRadius = outerRadius / 2
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
            self.layer.addSublayer(dotLayer)
            dots.append(dotLayer)
            
            // animate opacity
            if animationEnabled {
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = 0.25
                animation.fromValue = 0
                animation.toValue = 1
                dotLayer.add(animation, forKey: "opacity")
            }
            
        }
        dotsDataStore.append(dots)
    }
    
    
    
    /**
    * Draw x and y axis.
    */
    func drawAxes() {
        let height = self.bounds.height
        let width = self.bounds.width
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(axesColor.cgColor)
        // draw x-axis
        context?.move(to: CGPoint(x: axisInset, y: height-axisInset))
        context?.addLine(to: CGPoint(x: width-axisInset, y: height-axisInset))
        context?.strokePath()
        // draw y-axis
        context?.move(to: CGPoint(x: axisInset, y: height-axisInset))
        context?.addLine(to: CGPoint(x: axisInset, y: axisInset))
        context?.strokePath()
    }
    
    
    
    /**
    * Get maximum value in all arrays in data store.
    */
    func getMaximumValue() -> CGFloat {
        var maximum = 1
        for data in dataStore {
            let newMaximum = data.reduce(Int.min, { max(Int($0), Int($1)) })
            if newMaximum > maximum {
                maximum = newMaximum + 2
            }
        }
        return CGFloat(maximum)
    }
    
    
    
    /**
    * Scale to fit drawing width.
    */
    func scaleDataXAxis(_ data: Array<CGFloat>) -> Array<CGFloat> {
        let factor = drawingWidth / CGFloat(data.count - 1)
        var scaledDataXAxis: Array<CGFloat> = []
        for index in 0..<data.count {
            let newXValue = factor * CGFloat(index)
            scaledDataXAxis.append(newXValue)
        }
        return scaledDataXAxis
    }
    
    
    
    /**
    * Scale data to fit drawing height.
    */
    func scaleDataYAxis(_ data: Array<CGFloat>) -> Array<CGFloat> {
        let maximumYValue = getMaximumValue()
        let factor = drawingHeight / maximumYValue
        let scaledDataYAxis = data.map({datum -> CGFloat in
            let newYValue = datum * factor
            return newYValue
        })
        return scaledDataYAxis
    }
    
    
    
    /**
    * Draw line.
    */
    func drawLine(_ xAxis: Array<CGFloat>, yAxis: Array<CGFloat>, lineIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: axisInset, y: self.bounds.height - yAxis[0] - axisInset))
        for index in 1..<xAxis.count {
            let xValue = xAxis[index] + axisInset
            let yValue = self.bounds.height - yAxis[index] - axisInset
            path.addLine(to: CGPoint(x: xValue, y: yValue))
        }
        
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path
        layer.strokeColor = color.cgColor
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)
        
        // animate line drawing
        if animationEnabled {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = animationDuration
            animation.fromValue = 0
            animation.toValue = 1
            layer.add(animation, forKey: "strokeEnd")
        }
        
        // add line layer to store
        lineLayerStore.append(layer)
    }
    
    func drawWordLine(_ lineIndex: Int) {
        // keep index within bounds

        var indexToDisplayLine = lineIndex
        if indexToDisplayLine < 0 {
            indexToDisplayLine = 0
        }
        if indexToDisplayLine > 23 {
            indexToDisplayLine = 23
        }
        
        // get axis
        var xAxis:Array<CGFloat> = scaleDataXAxis(dataStore[0])
        
        // create path and draw line
        let path = CGMutablePath()
        path.move(to: CGPoint(x: xAxis[indexToDisplayLine] + axisInset, y: self.bounds.minY + axisInset))
        path.addLine(to: CGPoint(x: xAxis[indexToDisplayLine] + axisInset, y: self.bounds.maxY + 10))
        
        // add line to screen
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path
        layer.strokeColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 0.4).cgColor
        layer.lineWidth = lineWidth * 2
        self.layer.addSublayer(layer)
        
        // add line to the line store so it can be cleared when touch is moved/ended
        lineHighlightLayerStore.append(layer)
    }
    
    func removeWordLine() {
        for lineLayer in lineHighlightLayerStore {
            lineLayer.removeFromSuperlayer()
        }
        lineHighlightLayerStore.removeAll()
    }
    
    /**
    * Fill area between line chart and x-axis.
    */
    func drawAreaBeneathLineChart(_ xAxis: Array<CGFloat>, yAxis: Array<CGFloat>, lineIndex: Int) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.withAlphaComponent(0.2).cgColor)
        // move to origin
        context?.move(to: CGPoint(x: axisInset, y: self.bounds.height - axisInset))
        // add line to first data point
        context?.addLine(to: CGPoint(x: axisInset, y: self.bounds.height - yAxis[0] - axisInset))
        // draw whole line chart
        for index in 1..<xAxis.count {
            let xValue = xAxis[index] + axisInset
            let yValue = self.bounds.height - yAxis[index] - axisInset
            context?.addLine(to: CGPoint(x: xValue, y: yValue))
        }
        // move down to x axis
        context?.addLine(to: CGPoint(x: xAxis[xAxis.count-1] + axisInset, y: self.bounds.height - axisInset))
        // move to origin
        context?.addLine(to: CGPoint(x: axisInset, y: self.bounds.height - axisInset))
        context?.fillPath()
    }
    
    
    
    /**
    * Fill area between charts.
    */
    func drawAreaBetweenLineCharts() {
        
        var xAxis = scaleDataXAxis(dataStore[0])
        var yAxisDataA = scaleDataYAxis(dataStore[areaBetweenLines[0]])
        var yAxisDataB = scaleDataYAxis(dataStore[areaBetweenLines[1]])
        var difference = yAxisDataA - yAxisDataB
        
        for index in 0..<xAxis.count-1 {
            
            let context = UIGraphicsGetCurrentContext()
            
            if difference[index] < 0 {
                context?.setFillColor(negativeAreaColor.cgColor)
            } else {
                context?.setFillColor(positiveAreaColor.cgColor)
            }
            
            let point1XValue = xAxis[index] + axisInset
            let point1YValue = self.bounds.height - yAxisDataA[index] - axisInset
            let point2XValue = xAxis[index] + axisInset
            let point2YValue = self.bounds.height - yAxisDataB[index] - axisInset
            let point3XValue = xAxis[index+1] + axisInset
            let point3YValue = self.bounds.height - yAxisDataB[index+1] - axisInset
            let point4XValue = xAxis[index+1] + axisInset
            let point4YValue = self.bounds.height - yAxisDataA[index+1] - axisInset
            
            context?.move(to: CGPoint(x: point1XValue, y: point1YValue))
            context?.addLine(to: CGPoint(x: point2XValue, y: point2YValue))
            context?.addLine(to: CGPoint(x: point3XValue, y: point3YValue))
            context?.addLine(to: CGPoint(x: point4XValue, y: point4YValue))
            context?.addLine(to: CGPoint(x: point1XValue, y: point1YValue))
            context?.fillPath()
            
        }
        
    }
    
    
    
    /**
    * Draw x grid.
    */
    func drawXGrid() {
        let space = drawingWidth / numberOfGridLinesX
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(gridColor.cgColor)
        for index in 1...Int(numberOfGridLinesX) {
            context?.move(to: CGPoint(x: axisInset + (CGFloat(index) * space), y: self.bounds.height - axisInset))
            context?.addLine(to: CGPoint(x: axisInset + (CGFloat(index) * space), y: axisInset))
        }
        context?.strokePath()
    }
    
    
    
    /**
    * Draw y grid.
    */
    func drawYGrid() {
        let maximumYValue = getMaximumValue()
        var step = Int(maximumYValue) / Int(numberOfGridLinesY)
        step = step == 0 ? 1 : step
        let height = drawingHeight / maximumYValue
        let context = UIGraphicsGetCurrentContext()
        for index in stride(from: 0, to: Int(maximumYValue), by: step) {
            context?.move(to: CGPoint(x: axisInset, y: self.bounds.height - (CGFloat(index) * height) - axisInset))
            context?.addLine(to: CGPoint(x: self.bounds.width - axisInset, y: self.bounds.height - (CGFloat(index) * height) - axisInset))
        }
        context?.strokePath()
    }
    
    
    
    /**
    * Draw grid.
    */
    func drawGrid() {
        drawXGrid()
        drawYGrid()
    }
    
    
    
    /**
    * Draw x labels.
    */
    func drawXLabels() {
        let xAxisData = self.dataStore[0]
        let scaledDataXAxis = scaleDataXAxis(xAxisData)
        for (index, scaledValue) in scaledDataXAxis.enumerated() {
            // MARK: mod - added modulo for division of label number display
            if index % 6 == 0 {
                let label = UILabel(frame: CGRect(x: scaledValue + (axisInset/2) + 2, y: self.bounds.height + axisInset, width: 44, height: axisInset))
                label.font = UIFont(name: "HelveticaNeue-Light",
                    size: 15.0)
                let lightGray:UIColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.4)

                // MARK: mod - changed justification
                label.textAlignment = NSTextAlignment.center

                // MARK: mod - hour time
                let timeStringIn12HourTime:String = graphIndexToTimeString(index, longForm: false)
                
                let labelText:NSMutableAttributedString = NSMutableAttributedString(string: timeStringIn12HourTime)
                labelText.addAttribute(NSForegroundColorAttributeName, value: lightGray, range: NSMakeRange(0, labelText.length))
                
                label.attributedText = labelText
                
                self.addSubview(label)
            }
        }
    }
    
    
    
    /**
    * Draw y labels.
    */
    func drawYLabels() {
        let maximumYValue = getMaximumValue()
        var step = Int(maximumYValue) / Int(numberOfGridLinesY)
        step = step == 0 ? 1 : step
        let height = drawingHeight / maximumYValue
        for index in stride(from: 0, to: Int(maximumYValue), by: step) {
            let yValue = self.bounds.height - (CGFloat(index) * height) - (axisInset * 1.5)
            let label = UILabel(frame: CGRect(x: 0, y: yValue, width: axisInset, height: axisInset))
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = NSTextAlignment.center
            label.text = String(index)
            self.addSubview(label)
        }
    }
    
    
    
    /**
    * Add line chart
    */
    func addLine(_ data: Array<CGFloat>) {
        self.dataStore.append(data)
        self.setNeedsDisplay()
    }
    
    
    /**
    * Make whole thing white again.
    */
    func clearAll() {
        self.removeAll = true
        clear()
        self.setNeedsDisplay()
        self.removeAll = false
    }
    
    
    
    /**
    * Remove charts, areas and labels but keep axis and grid.
    */
    func clear() {
        // clear data
        dataStore.removeAll()
        self.setNeedsDisplay()
    }

}

/**
* Convert hex color to UIColor
*/
func UIColorFromHex(_ hex: Int) -> UIColor {
    let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
    let blue = CGFloat((hex & 0xFF)) / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

// graphIndexToTimeString takes a graphIndex and a boolean that relays whether or not we would like longform times (10:00 AM is long-form, 10AM isn't)
// in return. This function is very specifically used by lineChart and SpotDetailViewController to respond to the user's touches on a LineChart object and
// display the time represented by that x-coordinate on the graph to the user on a corresponding label somewhere in that view.
func graphIndexToTimeString(_ graphIndex: Int, longForm: Bool) -> String {
    
    // temporary storage of strings
    var stringHour = ""
    var stringLongForm = ""
    var string12HourExtension = ""
    
    // get hour of day
    var hourOfDay = Int(graphIndex)
    
    // return "Now" if the user has touched an index on a 24-hour graph that represents the current hour of the day
    if hourOfDay == Date().hour()  {
        return "Now"
    }
    
    // find stringHour
    if hourOfDay < 12 {
        string12HourExtension = "AM"
        if hourOfDay == 0 {
            stringHour = "12"
        }
        else {
            stringHour = "\(hourOfDay)"
        }
    }
    else if hourOfDay >= 12 {
        string12HourExtension = "PM"
        if hourOfDay == 23 {
            stringHour = "11"
        }
        else {
            hourOfDay = hourOfDay - 12
            if hourOfDay == 0 {
                stringHour = "12"
            }
            else {
                stringHour = "\(hourOfDay)"
            }
        }
    }
    
    if longForm {
        stringLongForm = ":00"
    }
    
    return "\(stringHour)\(stringLongForm) \(string12HourExtension)"
}
