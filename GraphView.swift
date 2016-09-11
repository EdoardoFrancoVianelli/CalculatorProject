//
//  GraphView.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

protocol GraphViewDelegate{
    func RenderingStarted()
    func RenderingEnded(iterations : Int)
}

extension CGRect
{
    func OutOfBouns() -> Bool
    {
        return XOutOfBounds() || YOutOfBounds()
    }
    
    func XOutOfBounds() -> Bool
    {
        return (origin.x + size.width > UIScreen.mainScreen().bounds.size.width)
    }
    
    func YOutOfBounds() -> Bool
    {
        return (origin.y + size.height > UIScreen.mainScreen().bounds.size.height)
    }
}

extension String{
    var Count : Int{
        return self.characters.count
    }
}

@IBDesignable
class GraphView: UIView {
    
    override var bounds: CGRect{ didSet{ AllSet = true } }
    
    @IBInspectable
    var MinX : CGFloat = -10.0
    
    @IBInspectable
    var MaxX : CGFloat = 10.0
    
    @IBInspectable
    var MinY : CGFloat = -10.0
    
    @IBInspectable
    var MaxY : CGFloat = 10.0
    
    @IBInspectable
    var AxisWidth : CGFloat = 1.0
    
    @IBInspectable
    var XScale : CGFloat = 1.0

    @IBInspectable
    var YScale : CGFloat = 1.0
    
    var AllSet : Bool = false{
        didSet {
            AllSetChanged()
        }
    }
    
    private var LastIterations = 0
    
    private func ReRender()
    {
        if AllSet
        {
            (delegate as? GraphViewDelegate)?.RenderingStarted()
            RenewTickDimensions()
            XAxis = ComputeXAxis(CGFloat(YPoint(0.0)), AxisWidth: AxisWidth, GraphWidth: frame.size.width)
            YAxis = ComputeYAxis(CGFloat(XPoint(0.0)), AxisWidth: AxisWidth, GraphHeight: frame.size.height)
            x_ticks = [GraphTick]()
            y_ticks = [GraphTick]()
            ComputeXTicks(&x_ticks)
            ComputeYTicks(&y_ticks)
            (lines, LastIterations) = ComputeEquations(["x", "x^2", "x^3"])
            self.setNeedsDisplay()
        }
    }
    
    private var _XTickWidth : CGFloat = 0.0
    private var _YTickHeight : CGFloat = 0.0
    
    private var XTickWidth : CGFloat { return _XTickWidth }
    private var YTickHeight : CGFloat { return _YTickHeight }
    
    private var XAxis = UIBezierPath()
    private var YAxis = UIBezierPath()
    
    private var x_ticks = [GraphTick]()
    private var y_ticks = [GraphTick]()
    
    private func XMinMaxDifference() -> CGFloat{
        let AbsMaxX = abs(MaxX)
        let AbsMinX = abs(MinX)
        var MinMaxDifference = AbsMaxX + AbsMinX
        if MaxX < 0{
            MinMaxDifference = AbsMinX - AbsMaxX
        }else if MinX > 0{
            MinMaxDifference = AbsMaxX - AbsMinX
        }else if !(MinX < 0 && MaxX > 0){
            //print("not hit case yet")
        }
        return MinMaxDifference
    }
    
    
    private func YMinMaxDifference() -> CGFloat{
        let AbsMaxY = abs(MaxY)
        let AbsMinY = abs(MinY)
        var MinMaxDifference = AbsMaxY + AbsMinY
        if MaxY < 0 {
            MinMaxDifference = AbsMinY - AbsMaxY
        }else if MinY > 0 {
            MinMaxDifference = AbsMaxY - AbsMinY
        }
        else if !(MinY < 0 && MaxY > 0){
            //print("not hit case yet")
        }
        return MinMaxDifference
    }
    
    private func GetXTickWidth() -> CGFloat
    {
        let MinMaxDifference = XMinMaxDifference()
        return frame.size.width / MinMaxDifference
    }
    
    private func GetYTickHeight() -> CGFloat
    {
        let MinMaxDifference = YMinMaxDifference()
        return frame.size.height / MinMaxDifference
    }
    
    private func RenewTickDimensions()
    {
        _XTickWidth = GetXTickWidth()
        _YTickHeight = GetYTickHeight()
    }
    
    @IBOutlet var delegate : AnyObject?
    private var FunctionLabels = [UILabel]()
    private var lines = [Line]()
    
    private var pointLabel = UILabel(frame: CGRect.zero)
    private var StartTime = NSDate(timeIntervalSinceNow: 0)
    private var StartLocation = CGPoint.zero
    
    private func AddTapToShowPointInfo()
    {
        let tapForPoint = UITapGestureRecognizer(target: self, action: #selector(UpdatePointLabel))
        tapForPoint.numberOfTapsRequired = 1
        addGestureRecognizer(tapForPoint)
    }
    
    private func AddTapToHidePointLabel(){
        let tapToHideGesture = UITapGestureRecognizer(target: self, action: #selector(TogglePointLabel))
        pointLabel.addGestureRecognizer(tapToHideGesture)
    }
    
    internal func TogglePointLabel(sender : UITapGestureRecognizer){
        if let hidden = sender.view?.hidden{
            sender.view?.hidden = !hidden
        }
    }
    
    private func PointToString(point : CGPoint) -> String
    {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 3
        
        if let xPoint = formatter.stringFromNumber(NSNumber(float: Float(point.x)))
        {
            if let yPoint = formatter.stringFromNumber(NSNumber(float: Float(point.y)))
            {
                return " X = \(xPoint)\n Y = \(yPoint)"
            }
        }
        
        return "\(point)"
    }
    
    private func InitializePointLabel()
    {
        pointLabel.userInteractionEnabled = true
        pointLabel.adjustsFontSizeToFitWidth = true
        pointLabel.numberOfLines = 2
        addSubview(pointLabel)
    }
    
    internal func UpdatePointLabel(sender : UIGestureRecognizer)
    {
        SetPointLabelWithLocation(sender.locationInView(self))
    }
    
    private func SetPointLabelWithLocation(touchLocation : CGPoint){
        pointLabel.hidden = false
        let XYPoint = CoordinatesForPoint(Double(touchLocation.x), YCoordinateInScreen: Double(touchLocation.y))
        let labelText = PointToString(XYPoint)
        let labelHeight : CGFloat = 80
        var labelWidth : CGFloat = CGFloat( (labelText.characters.count / 2 ) * 10)
        if labelWidth > 100
        {
            labelWidth = 100
        }
        pointLabel.frame = CGRect(x: touchLocation.x, y: touchLocation.y, width: labelWidth, height: labelHeight)
        
        if pointLabel.frame.XOutOfBounds()
        {
            pointLabel.frame.origin.x = UIScreen.mainScreen().bounds.size.width - 10 - pointLabel.frame.width
        }
        if pointLabel.frame.YOutOfBounds()
        {
            pointLabel.frame.origin.y = UIScreen.mainScreen().bounds.size.height - 10 - pointLabel.frame.height
        }
        
        pointLabel.text = labelText
        //position the cursor
    }
    
    func ConfigureMovePointLabel()
    {
        let moveLabelGesture = UIPanGestureRecognizer(target: self, action: #selector(MovePointLabel))
        pointLabel.addGestureRecognizer(moveLabelGesture)
    }
    
    func MovePointLabel(sender : UIPanGestureRecognizer)
    {
        pointLabel.frame.origin = sender.locationInView(self)
        UpdatePointLabel(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Initialize()
    }
    
    func Initialize()
    {
        ConfigurePinchGesture()
        AddTapToShowPointInfo()
        AddTapToHidePointLabel()
        ConfigureMovePointLabel()
        InitializePointLabel()
        AllSet = true
    }
    
    private let TickMarkerSize = 15 as CGFloat
    
    private func LongestDigits(left : Double, right : Double) -> (length : Int, number : Double){
        let leftLength = "\(left)".characters.count
        let rightLength = "\(right)".characters.count
        return leftLength > rightLength ? (leftLength, left) : (rightLength, right)
    }
    
    private func OptimalSkippingFactor(min : CGFloat, max : CGFloat, y : Bool) -> CGFloat
    {
        let greatestValue = (abs(min.description.Count) > abs(max.description.Count)) ? min : max
        let locationOfGreatestValue = y ? YPoint(Double(greatestValue)) : XPoint(Double(greatestValue))
        let attributedGreatestValue = NSAttributedString(string: greatestValue.description)
        let valueDimension = y ? ((attributedGreatestValue.size().height / 2) + 10) : ((attributedGreatestValue.size().width / 2) + 10)
        let greatestBounds : (lower : Double, upper : Double) = (locationOfGreatestValue - Double(valueDimension), locationOfGreatestValue + Double(valueDimension))
        let lowerBoundPoint = CGFloat(RectXPoint(greatestBounds.lower))
        let upperBoundPoint = CGFloat(RectXPoint(greatestBounds.upper))
        let newSkippingFactor = abs(upperBoundPoint - lowerBoundPoint)
        return round(newSkippingFactor)
    }
    
    private func ComputeOptimalSkippingFactor() -> CGFloat
    {
        return OptimalSkippingFactor(MinX, max: MaxX, y: false)
    }
    
    private func ComputeXTicks(inout XTicks : [GraphTick]){
        
        var previous : GraphTick?
        let Start = -(abs(MinX) - (abs(MinX) % XScale)) + 1
        
        var iterations = 0
        var skippingFactor = ComputeOptimalSkippingFactor()
        if skippingFactor <= 0{
            skippingFactor = XScale
        }
        //print("The skipping factor is \(skippingFactor)")
        
        for CurrentX in Start.stride(to: MaxX, by: skippingFactor){
            let ScreenCoordinates = PointForCoordinates(Double(CurrentX), y: 0.0)
            let CurrentTick = GraphTick(number: Double(CurrentX), y: false)
            let StartPoint = CGPoint(x: ScreenCoordinates.x, y: ScreenCoordinates.y - TickMarkerSize / 2)
            let EndPoint = CGPoint(x: StartPoint.x, y: StartPoint.y + TickMarkerSize)
            CurrentTick.SetTickPath(StartPoint, end: EndPoint, width: AxisWidth)
            CurrentTick.SetNumberLocation(CGPoint(x: EndPoint.x - CurrentTick.NumberFrame.size.width, y: EndPoint.y + 5))
            
            if let prev = previous{
                //let xDifference = abs((prev.NumberFrame.origin.x + prev.NumberFrame.size.width) - CurrentTick.NumberFrame.origin.x)
                if !prev.NumberFrame.intersects(CurrentTick.NumberFrame){
                    XTicks.append(CurrentTick)
                    previous = CurrentTick
                }
            }else{
                XTicks.append(CurrentTick)
                previous = CurrentTick
            }
            iterations += 1
        }
        
        print("Iterations for x ticks is \(iterations)")
    }
    
    private func ComputeYTicks(inout YTicks : [GraphTick]){
        var previous : GraphTick?
        let Start = -(abs(MinY) - (abs(MinY) % YScale)) + 1
        var iterations = 0
        
        var skippingFactor = OptimalSkippingFactor(MinY, max: MaxY, y: true)
        if skippingFactor <= 0{
            skippingFactor = YScale
        }

        for CurrentY in Start.stride(to: MaxY, by: skippingFactor){
            let ScreenCoordinates = PointForCoordinates(0.0, y: Double(CurrentY))
            let CurrentTick = GraphTick(number: Double(CurrentY), y: true)
            let StartPoint = CGPoint(x: ScreenCoordinates.x - TickMarkerSize / 2, y: ScreenCoordinates.y)
            let EndPoint = CGPoint(x: StartPoint.x + TickMarkerSize, y: StartPoint.y)
            CurrentTick.SetTickPath(StartPoint, end: EndPoint, width: AxisWidth)
            CurrentTick.SetNumberLocation(CGPoint(x: EndPoint.x + TickMarkerSize / 2 , y: EndPoint.y - CurrentTick.NumberFrame.size.height / 2))
            if let prev = previous{
                let yDifference = prev.NumberFrame.origin.y - (CurrentTick.NumberFrame.origin.y + CurrentTick.NumberFrame.height)
                if !prev.NumberFrame.intersects(CurrentTick.NumberFrame) && yDifference >= 10{
                    YTicks.append(CurrentTick)
                    previous = CurrentTick
                }else if yDifference < 10{
                    
                }
            }else{
                YTicks.append(CurrentTick)
                previous = CurrentTick
            }
            iterations += 1
        }
        print("Y tick iterations is \(iterations)")
    }
    
    private func ComputeEquations(equations : [String]) -> ([Line], iterations : Int)
    {
        var ResultingEquations = [Line]()
        
        var num = 0
        
        for (i,equation) in equations.enumerate()
        {
            var CurrentEquation = Line(Expression: equation, numLines: i)
            
            let calculator = ExpressionEvaluator(expression: equation)
            
            var Previous : GraphTick?
            
            for i in 0.stride(to: x_ticks.count, by: 1){
                let Current = x_ticks[i]
                let lowerBound = (Previous != nil) ? Previous!.Number : Double(MinX)
                let upperBound = Current.Number
                
                
                for x in lowerBound.stride(to: upperBound, by: (upperBound - lowerBound) / 4){
                    calculator.SetVariableValue("x", value: x)
                    let Point = PointForCoordinates(x, y: calculator.Result)
                    CurrentEquation.AddPoint(Point)
                    num += 1
                }
                Previous = Current
            }
            
            ResultingEquations.append(CurrentEquation)
            UpdateFunctionLabel(calculator.Expression, color: CurrentEquation.Color, i: i)
        }
        
        print("\(num) iterations to render all functions")
        
        return (ResultingEquations, num)
    }
    
    let cursorDimension : CGFloat = 30
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        UIColor.blackColor().set()
        XAxis.stroke()
        YAxis.stroke()
        
        for tick in y_ticks{
            tick.draw()
        }
        for tick in x_ticks{
            tick.draw()
        }
        
        for line in lines { line.Draw() }
        
        //if !pointLabel.hidden { SetPointLabelWithLocation(pointLabel.frame.origin) }
        
        AllSet = false
        
        (delegate as? GraphViewDelegate)?.RenderingEnded(LastIterations)
    }
    
    private func TickFormatter() -> NSNumberFormatter{
        let formatter = NSNumberFormatter()
        formatter.maximumSignificantDigits = 3
        return formatter
    }
        
    private func RectXPoint(XCoordinateInScreen : Double) -> Double
    {
        return (XCoordinateInScreen / Double(XTickWidth)) - Double(abs(MinX))
    }
    
    private func RectYPoint(YCoordinateInScreen : Double) -> Double
    {
        return Double(abs(MaxY)) - (YCoordinateInScreen / Double(YTickHeight))
    }
    
    internal func CoordinatesForPoint(XCoordinateInScreen : Double, YCoordinateInScreen : Double) -> CGPoint
    {
        return CGPoint(x: RectXPoint(XCoordinateInScreen), y: RectYPoint(YCoordinateInScreen))
    }
    
    private func ComputeXAxis(YLocation : CGFloat, AxisWidth : CGFloat, GraphWidth : CGFloat) -> UIBezierPath
    {
        let XAxis = UIBezierPath()
        
        XAxis.moveToPoint(CGPoint(x: 0.0, y: YLocation))
        XAxis.addLineToPoint(CGPoint(x: GraphWidth, y: YLocation))
        XAxis.lineWidth = AxisWidth
        
        return XAxis
    }
    
    private func ComputeYAxis(XLocation : CGFloat, AxisWidth : CGFloat, GraphHeight : CGFloat) -> UIBezierPath
    {
        let YAxis = UIBezierPath()
        
        YAxis.moveToPoint(CGPoint(x: XLocation, y: 0.0))
        YAxis.addLineToPoint(CGPoint(x: XLocation, y: GraphHeight))
        YAxis.lineWidth = AxisWidth
        
        return YAxis
    }
    
    private func XAxisStartLocation() -> Double
    {
        //we know that the minimum is at zero
        return Double(-1 * MinX * XTickWidth)
    }
    
    private func YAxisSstartLocation() -> Double
    {
        return Double(MaxY * YTickHeight)
    }
    
    private func XPoint(x : Double) -> Double
    {
        return XAxisStartLocation() + (Double(XTickWidth) * x)
    }
    
    private func YPoint(y : Double) -> Double
    {
        let start = YAxisSstartLocation()
        return start - (Double(YTickHeight) * y)
    }
    
    internal func PointForCoordinates(x : Double, y : Double) -> CGPoint
    {
        return CGPoint(x: XPoint(x), y: YPoint(y))
    }
    
    func LabelAttributedText(expression : String, index : Int, highlighted : Bool) -> NSAttributedString{
        let functionText = "Y\(index) = " + expression
        let attr_string = NSMutableAttributedString(string: functionText)
        let fontSize : CGFloat = 16
        if highlighted{
            attr_string.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(fontSize), range: NSRange(location: 0, length: expression.characters.count))
        }else{
            attr_string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(fontSize), range: NSRange(location: 0, length: expression.characters.count))
        }
        return attr_string
    }
    
    private func UpdateFunctionLabel(expression : String, color : UIColor, i : Int)
    {
        let attributedText = LabelAttributedText(expression, index: i, highlighted: false)
        if i >= FunctionLabels.count
        {
            FunctionLabels.append(UILabel())
            addSubview(FunctionLabels[i])
        }
        FunctionLabels[i].frame.origin = CGPoint(x: 20, y: 20 + 30 * i)
        FunctionLabels[i].frame.size = CGSize(width: CGFloat(attributedText.string.characters.count) * 10, height: 30)
        FunctionLabels[i].attributedText = attributedText
        FunctionLabels[i].textColor = color
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(HandleTapLabel))
        tapAction.numberOfTapsRequired = 1
        FunctionLabels[i].addGestureRecognizer(tapAction)
        FunctionLabels[i].userInteractionEnabled = true
    }
    
    internal func HandleTapLabel(sender : UITapGestureRecognizer){
        if let text = (sender.view as? UILabel)?.text{
            if let number = NSNumberFormatter().numberFromString("\(text[text.startIndex.advancedBy(1)])")?.integerValue{
                lines[number].width = AxisWidth * 2
                FunctionLabels[number].attributedText = LabelAttributedText(lines[number].Expression, index: number, highlighted: true)
                
                for i in 0..<lines.count{
                    if (i == number){
                        continue
                    }
                    lines[i].width = AxisWidth
                    FunctionLabels[i].attributedText = LabelAttributedText(lines[i].Expression, index: i, highlighted: true)
                }
                
                self.setNeedsDisplay()
            }
        }
    }
    
    //MARK: Graph shift stuff
    
    func MoveLeft(){
        MinX += XScale
        MaxX += XScale
        AllSet = true
    }
    
    func MoveRight(){
        MinX -= XScale
        MaxX -= XScale
        AllSet = true
    }
    
    func MoveUp(){
        MaxY += YScale
        MinY += YScale
        AllSet = true
    }
    
    func MoveDown(){
        MaxY -= YScale
        MinY -= YScale
        AllSet = true
    }
    
    func Zoom(scale : CGFloat){
        let adjustedScale = 1 / scale
        MaxX *= adjustedScale
        MinX *= adjustedScale
        MaxY *= adjustedScale
        MinY *= adjustedScale
        AllSet = true
    }
    
    func ZoomIn(){
        Zoom(2)
    }
    
    func ZoomOut(){
        Zoom(0.5)
    }
    
    //MARK: Gesture Stuff
    
    func ConfigurePinchGesture()
    {
        let PinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ManagePinch))
        self.addGestureRecognizer(PinchGesture)
    }
    
    func ManagePinch(gesture : UIPinchGestureRecognizer)
    {
        if gesture.state == UIGestureRecognizerState.Failed { return }

        let Scale = 1 / gesture.scale
        
        
        MaxX *= Scale
        MaxY *= Scale
        MinX *= Scale
        MinY *= Scale
        
        AllSet = true
        ReRender()
        
//        print("Scale is \(Scale)")
    }
    
    private func UpdateStartTimeAndLocation(sender : UIGestureRecognizer)
    {
        StartTime = NSDate(timeIntervalSinceNow: 0)
        StartLocation = sender.locationInView(self)
    }
    
    private func ConfigurePanGesture() {
        let PanGesture = UIPanGestureRecognizer(target: self, action: #selector(ManagePan))
        addGestureRecognizer(PanGesture)
    }
    
    func ManagePan(sender : UIPanGestureRecognizer)
    {
//        print("Start point is \(StartLocation)")
        
        switch sender.state {
        case .Began:
            UpdateStartTimeAndLocation(sender)
        case .Ended:
            let velocity = sender.velocityInView(self)
            let time = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(StartTime)
            if time < 0 {
//                print("TIME IS NEGATIVE \(time)")
            }
            let distances = CGPoint(x: Double(velocity.x) * time, y: Double(velocity.y) * time) + StartLocation
            let pointsElapsed = CoordinatesForPoint(Double(distances.x), YCoordinateInScreen: Double(distances.y))
//            print("Distances are \(distances) Points Elapsed: \(pointsElapsed)")
            
            //apply the changes
            
            MinX -= pointsElapsed.x
            MaxX -= pointsElapsed.x
            
            MinY -= pointsElapsed.y
            MaxY -= pointsElapsed.y
            
            AllSet = true
            ReRender()
            
            // ++ -- +- -+
            
            //panning down, y is negative, this should make the graph go up, so it should increase Y max
            //panning   up, y is positive, this should make the graph go down, so it should decrease Y min
            
            UpdateStartTimeAndLocation(sender)
        default:
            break
        }
    }
    
    //MARK: GraphModelDelegate
    
    func AllSetChanged() {
        ReRender()
    }
}

func + (left : CGPoint, right : CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func LinePath(fromPoint p1 : CGPoint,
                                toPoint p2 : CGPoint,
                                        width : CGFloat) -> UIBezierPath
{
    let Line = UIBezierPath()
    Line.moveToPoint(p1)
    Line.addLineToPoint(p2)
    Line.lineWidth = width
    return Line
}

infix operator +- {associativity left}


func +- (left : Double, right : Double) -> (left : Double, right : Double){
    return (left - right, left + right)
}






















