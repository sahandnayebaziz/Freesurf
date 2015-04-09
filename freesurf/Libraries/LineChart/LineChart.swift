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
        var difference = left[index] - right[index]
        result.append(difference)
    }
    return result
}

// delegate method
@objc protocol LineChartDelegate {
    
    // modified to require a chartIdentifier to be sent to the delegate when this is called. This was added
    // when I created two LineChart objects in with the same viewController as delegate and could no think
    // of no other way to identify which LineChart object the touches were coming from.
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>, chartIdentifier: String)
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
    var dotsBackgroundColor = UIColor.whiteColor()
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
    var colors: Array<UIColor> = []
    
    var removeAll: Bool = false
    
    // necessary init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        // category10 colors from d3 - https://github.com/mbostock/d3/wiki/Ordinal-Scales
        self.colors = [
            UIColorFromHex(0x1f77b4),
            UIColorFromHex(0xff7f0e),
            UIColorFromHex(0x2ca02c),
            UIColorFromHex(0xd62728),
            UIColorFromHex(0x9467bd),
            UIColorFromHex(0x8c564b),
            UIColorFromHex(0xe377c2),
            UIColorFromHex(0x7f7f7f),
            UIColorFromHex(0xbcbd22),
            UIColorFromHex(0x17becf)
        ]
    }
    
    // necessary init
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    // necessary init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // intitialization added to take indentifer to be used as chartIdentifier
    init(frame: CGRect, identifier: String) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.colors = [
            UIColorFromHex(0x1f77b4),
            UIColorFromHex(0xff7f0e),
            UIColorFromHex(0x2ca02c),
            UIColorFromHex(0xd62728),
            UIColorFromHex(0x9467bd),
            UIColorFromHex(0x8c564b),
            UIColorFromHex(0xe377c2),
            UIColorFromHex(0x7f7f7f),
            UIColorFromHex(0xbcbd22),
            UIColorFromHex(0x17becf)
        ]
        self.chartIdentifier = identifier
    }
    
    
    override func drawRect(rect: CGRect) {
        
        if removeAll {
            var context = UIGraphicsGetCurrentContext()
            CGContextClearRect(context, rect)
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
        for (lineIndex, lineData) in enumerate(dataStore) {
            var scaledDataXAxis = scaleDataXAxis(lineData)
            var scaledDataYAxis = scaleDataYAxis(lineData)
            drawLine(scaledDataXAxis, yAxis: scaledDataYAxis, lineIndex: lineIndex)
            
            // draw dots
            if dotsVisible { drawDataDots(scaledDataXAxis, yAxis: scaledDataYAxis, lineIndex: lineIndex) }
            
            // draw area under line chart
            if areaUnderLinesVisible { drawAreaBeneathLineChart(scaledDataXAxis, yAxis: scaledDataYAxis, lineIndex: lineIndex) }
            
        }
        
    }
    
    
    
    /**
    * Convert hex color to UIColor
    */
    func UIColorFromHex(hex: Int) -> UIColor {
        var red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        var blue = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
    
    /**
    * Lighten color.
    */
    func lightenUIColor(color: UIColor) -> UIColor {
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
    func getYValuesForXValue(x: Int) -> Array<CGFloat> {
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
    func handleTouchEvents(touches: NSSet!, event: UIEvent!) {
        if (self.dataStore.isEmpty) { return }
        var point: AnyObject! = touches.anyObject()
        var xValue = point.locationInView(self).x
        var closestXValueIndex = findClosestXValueInData(xValue)
        var yValues: Array<CGFloat> = getYValuesForXValue(closestXValueIndex)
        highlightDataPoints(closestXValueIndex)
//        drawWordLine(xValue)
        drawWordLine(closestXValueIndex)
        delegate?.didSelectDataPoint(CGFloat(closestXValueIndex), yValues: yValues, chartIdentifier: self.chartIdentifier)
    }
    
    // touchesBegan and touchesMoved are called if the user begins to or continues to touch
    // a LineChart object
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        removeWordLine()
        handleTouchEvents(touches, event: event)
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        removeWordLine()
        handleTouchEvents(touches, event: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        removeWordLine()
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent!) {
        removeWordLine()
    }
    
    // simulateTouchAtIndex takes an index and calls the delegate's didSelectDataPoint function at the given index
    // to simulate a touch at a given index on a LineChart object.
    func simulateTouchAtIndex(index: Int) {
        var yValues: Array<CGFloat> = getYValuesForXValue(index)
        highlightDataPoints(index)
        delegate?.didSelectDataPoint(CGFloat(index), yValues: yValues, chartIdentifier: self.chartIdentifier)
    }

    /**
    * Find closest value on x axis.
    */
    func findClosestXValueInData(xValue: CGFloat) -> Int {
        var scaledDataXAxis = scaleDataXAxis(dataStore[0])
        var difference = scaledDataXAxis[1] - scaledDataXAxis[0]
        var dividend = (xValue - axisInset) / difference
        var roundedDividend = Int(round(Double(dividend)))
        return roundedDividend
    }
    
    /**
    * Highlight data points at index.
    */
    func highlightDataPoints(index: Int) {
        for (lineIndex, dotsData) in enumerate(dotsDataStore) {
            // make all dots white again
            for dot in dotsData {
                if dot != dotsData[NSDate().hour()] {
                    dot.backgroundColor = dotsBackgroundColor.CGColor
                }
                else {
                    dot.backgroundColor = colors[lineIndex].CGColor
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

            dot.backgroundColor = UIColor.whiteColor().CGColor
        }
    }
    
    
    
    /**
    * Draw small dot at every data point.
    */
    func drawDataDots(xAxis: Array<CGFloat>, yAxis: Array<CGFloat>, lineIndex: Int) {
        var dots: Array<DotCALayer> = []
        for index in 0..<xAxis.count {
            var xValue = xAxis[index] + axisInset - outerRadius/2
            var yValue = self.bounds.height - yAxis[index] - axisInset - outerRadius/2
            
            // draw custom layer with another layer in the center
            var dotLayer = DotCALayer()
            dotLayer.dotInnerColor = colors[lineIndex]
            dotLayer.innerRadius = innerRadius
            dotLayer.backgroundColor = dotsBackgroundColor.CGColor
            dotLayer.cornerRadius = outerRadius / 2
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
            self.layer.addSublayer(dotLayer)
            dots.append(dotLayer)
            
            // animate opacity
            if animationEnabled {
                var animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = 0.25
                animation.fromValue = 0
                animation.toValue = 1
                dotLayer.addAnimation(animation, forKey: "opacity")
            }
            
        }
        dotsDataStore.append(dots)
    }
    
    
    
    /**
    * Draw x and y axis.
    */
    func drawAxes() {
        var height = self.bounds.height
        var width = self.bounds.width
        var context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axesColor.CGColor)
        // draw x-axis
        CGContextMoveToPoint(context, axisInset, height-axisInset)
        CGContextAddLineToPoint(context, width-axisInset, height-axisInset)
        CGContextStrokePath(context)
        // draw y-axis
        CGContextMoveToPoint(context, axisInset, height-axisInset)
        CGContextAddLineToPoint(context, axisInset, axisInset)
        CGContextStrokePath(context)
    }
    
    
    
    /**
    * Get maximum value in all arrays in data store.
    */
    func getMaximumValue() -> CGFloat {
        var maximum = 1
        for data in dataStore {
            var newMaximum = data.reduce(Int.min, combine: { max(Int($0), Int($1)) })
            if newMaximum > maximum {
                maximum = newMaximum + 2
            }
        }
        return CGFloat(maximum)
    }
    
    
    
    /**
    * Scale to fit drawing width.
    */
    func scaleDataXAxis(data: Array<CGFloat>) -> Array<CGFloat> {
        var factor = drawingWidth / CGFloat(data.count - 1)
        var scaledDataXAxis: Array<CGFloat> = []
        for index in 0..<data.count {
            var newXValue = factor * CGFloat(index)
            scaledDataXAxis.append(newXValue)
        }
        return scaledDataXAxis
    }
    
    
    
    /**
    * Scale data to fit drawing height.
    */
    func scaleDataYAxis(data: Array<CGFloat>) -> Array<CGFloat> {
        var maximumYValue = getMaximumValue()
        var factor = drawingHeight / maximumYValue
        var scaledDataYAxis = data.map({datum -> CGFloat in
            var newYValue = datum * factor
            return newYValue
        })
        return scaledDataYAxis
    }
    
    
    
    /**
    * Draw line.
    */
    func drawLine(xAxis: Array<CGFloat>, yAxis: Array<CGFloat>, lineIndex: Int) {
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, axisInset, self.bounds.height - yAxis[0] - axisInset)
        for index in 1..<xAxis.count {
            var xValue = xAxis[index] + axisInset
            var yValue = self.bounds.height - yAxis[index] - axisInset
            CGPathAddLineToPoint(path, nil, xValue, yValue)
        }
        
        var layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path
        layer.strokeColor = colors[lineIndex].CGColor
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)
        
        // animate line drawing
        if animationEnabled {
            var animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = animationDuration
            animation.fromValue = 0
            animation.toValue = 1
            layer.addAnimation(animation, forKey: "strokeEnd")
        }
        
        // add line layer to store
        lineLayerStore.append(layer)
    }
    
    func drawWordLine(lineIndex: Int) {
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
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, xAxis[indexToDisplayLine] + axisInset, self.bounds.minY + axisInset)
        CGPathAddLineToPoint(path, nil, xAxis[indexToDisplayLine] + axisInset, self.bounds.maxY + 10)
        
        // add line to screen
        var layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path
        layer.strokeColor = UIColor(red: 97/255.0, green: 177/255.0, blue: 237/255.0, alpha: 0.4).CGColor
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
    func drawAreaBeneathLineChart(xAxis: Array<CGFloat>, yAxis: Array<CGFloat>, lineIndex: Int) {
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, colors[lineIndex].colorWithAlphaComponent(0.2).CGColor)
        // move to origin
        CGContextMoveToPoint(context, axisInset, self.bounds.height - axisInset)
        // add line to first data point
        CGContextAddLineToPoint(context, axisInset, self.bounds.height - yAxis[0] - axisInset)
        // draw whole line chart
        for index in 1..<xAxis.count {
            var xValue = xAxis[index] + axisInset
            var yValue = self.bounds.height - yAxis[index] - axisInset
            CGContextAddLineToPoint(context, xValue, yValue)
        }
        // move down to x axis
        CGContextAddLineToPoint(context, xAxis[xAxis.count-1] + axisInset, self.bounds.height - axisInset)
        // move to origin
        CGContextAddLineToPoint(context, axisInset, self.bounds.height - axisInset)
        CGContextFillPath(context)
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
            
            var context = UIGraphicsGetCurrentContext()
            
            if difference[index] < 0 {
                CGContextSetFillColorWithColor(context, negativeAreaColor.CGColor)
            } else {
                CGContextSetFillColorWithColor(context, positiveAreaColor.CGColor)
            }
            
            var point1XValue = xAxis[index] + axisInset
            var point1YValue = self.bounds.height - yAxisDataA[index] - axisInset
            var point2XValue = xAxis[index] + axisInset
            var point2YValue = self.bounds.height - yAxisDataB[index] - axisInset
            var point3XValue = xAxis[index+1] + axisInset
            var point3YValue = self.bounds.height - yAxisDataB[index+1] - axisInset
            var point4XValue = xAxis[index+1] + axisInset
            var point4YValue = self.bounds.height - yAxisDataA[index+1] - axisInset
            
            CGContextMoveToPoint(context, point1XValue, point1YValue)
            CGContextAddLineToPoint(context, point2XValue, point2YValue)
            CGContextAddLineToPoint(context, point3XValue, point3YValue)
            CGContextAddLineToPoint(context, point4XValue, point4YValue)
            CGContextAddLineToPoint(context, point1XValue, point1YValue)
            CGContextFillPath(context)
            
        }
        
    }
    
    
    
    /**
    * Draw x grid.
    */
    func drawXGrid() {
        var space = drawingWidth / numberOfGridLinesX
        var context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
        for index in 1...Int(numberOfGridLinesX) {
            CGContextMoveToPoint(context, axisInset + (CGFloat(index) * space), self.bounds.height - axisInset)
            CGContextAddLineToPoint(context, axisInset + (CGFloat(index) * space), axisInset)
        }
        CGContextStrokePath(context)
    }
    
    
    
    /**
    * Draw y grid.
    */
    func drawYGrid() {
        var maximumYValue = getMaximumValue()
        var step = Int(maximumYValue) / Int(numberOfGridLinesY)
        step = step == 0 ? 1 : step
        var height = drawingHeight / maximumYValue
        var context = UIGraphicsGetCurrentContext()
        for var index = 0; index <= Int(maximumYValue); index += step {
            CGContextMoveToPoint(context, axisInset, self.bounds.height - (CGFloat(index) * height) - axisInset)
            CGContextAddLineToPoint(context, self.bounds.width - axisInset, self.bounds.height - (CGFloat(index) * height) - axisInset)
        }
        CGContextStrokePath(context)
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
        var xAxisData = self.dataStore[0]
        var scaledDataXAxis = scaleDataXAxis(xAxisData)
        for (index, scaledValue) in enumerate(scaledDataXAxis) {
            // MARK: mod - added modulo for division of label number display
            if index % 6 == 0 {
                var label = UILabel(frame: CGRect(x: scaledValue + (axisInset/2) + 2, y: self.bounds.height + axisInset, width: 44, height: axisInset))
                label.font = UIFont(name: "HelveticaNeue-Light",
                    size: 15.0)
                let lightGray:UIColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.4)

                // MARK: mod - changed justification
                label.textAlignment = NSTextAlignment.Center

                // MARK: mod - hour time
                var timeStringIn12HourTime:String = graphIndexToTimeString(index, false)
                
                var labelText:NSMutableAttributedString = NSMutableAttributedString(string: timeStringIn12HourTime)
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
        var maximumYValue = getMaximumValue()
        var step = Int(maximumYValue) / Int(numberOfGridLinesY)
        step = step == 0 ? 1 : step
        var height = drawingHeight / maximumYValue
        for var index = 0; index <= Int(maximumYValue); index += step {
            var yValue = self.bounds.height - (CGFloat(index) * height) - (axisInset * 1.5)
            var label = UILabel(frame: CGRect(x: 0, y: yValue, width: axisInset, height: axisInset))
            label.font = UIFont.systemFontOfSize(10)
            label.textAlignment = NSTextAlignment.Center
            label.text = String(index)
            self.addSubview(label)
        }
    }
    
    
    
    /**
    * Add line chart
    */
    func addLine(data: Array<CGFloat>) {
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

// graphIndexToTimeString takes a graphIndex and a boolean that relays whether or not we would like longform times (10:00 AM is long-form, 10AM isn't)
// in return. This function is very specifically used by lineChart and SpotDetailViewController to respond to the user's touches on a LineChart object and
// display the time represented by that x-coordinate on the graph to the user on a corresponding label somewhere in that view.
func graphIndexToTimeString(graphIndex: Int, longForm: Bool) -> String {
    
    // temporary storage of strings
    var stringHour = ""
    var stringLongForm = ""
    var string12HourExtension = ""
    
    // get hour of day
    var hourOfDay = Int(graphIndex)
    
    // return "Now" if the user has touched an index on a 24-hour graph that represents the current hour of the day
    if hourOfDay == NSDate().hour()  {
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