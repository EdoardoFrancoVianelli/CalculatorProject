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
    func RenderingEnded(_ iterations : Int)
}

extension CGRect
{
    func OutOfBouns() -> Bool
    {
        return XOutOfBounds() || YOutOfBounds()
    }
    
    func XOutOfBounds() -> Bool
    {
        return (origin.x + size.width > UIScreen.main.bounds.size.width)
    }
    
    func YOutOfBounds() -> Bool
    {
        return (origin.y + size.height > UIScreen.main.bounds.size.height)
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
    
    fileprivate var LastIterations = 0
    
    fileprivate func ReRender()
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
    
    fileprivate var _XTickWidth : CGFloat = 0.0
    fileprivate var _YTickHeight : CGFloat = 0.0
    
    fileprivate var XTickWidth : CGFloat { return _XTickWidth }
    fileprivate var YTickHeight : CGFloat { return _YTickHeight }
    
    fileprivate var XAxis = UIBezierPath()
    fileprivate var YAxis = UIBezierPath()
    
    fileprivate var x_ticks = [GraphTick]()
    fileprivate var y_ticks = [GraphTick]()
    
    fileprivate func XMinMaxDifference() -> CGFloat{
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
    
    
    fileprivate func YMinMaxDifference() -> CGFloat{
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
    
    fileprivate func GetXTickWidth() -> CGFloat
    {
        let MinMaxDifference = XMinMaxDifference()
        return frame.size.width / MinMaxDifference
    }
    
    fileprivate func GetYTickHeight() -> CGFloat
    {
        let MinMaxDifference = YMinMaxDifference()
        return frame.size.height / MinMaxDifference
    }
    
    fileprivate func RenewTickDimensions()
    {
        _XTickWidth = GetXTickWidth()
        _YTickHeight = GetYTickHeight()
    }
    
    @IBOutlet var delegate : AnyObject?
    fileprivate var FunctionLabels = [UILabel]()
    fileprivate var lines = [Line]()
    
    fileprivate var pointLabel = UILabel(frame: CGRect.zero)
    
    fileprivate func AddTapToShowPointInfo()
    {
        let tapForPoint = UITapGestureRecognizer(target: self, action: #selector(UpdatePointLabel))
        tapForPoint.numberOfTapsRequired = 1
        addGestureRecognizer(tapForPoint)
    }
    
    fileprivate func AddTapToHidePointLabel(){
        let tapToHideGesture = UITapGestureRecognizer(target: self, action: #selector(TogglePointLabel))
        pointLabel.addGestureRecognizer(tapToHideGesture)
    }
    
    internal func TogglePointLabel(_ sender : UITapGestureRecognizer){
        if let hidden = sender.view?.isHidden{
            sender.view?.isHidden = !hidden
        }
    }
    
    fileprivate func PointToString(_ point : CGPoint) -> String
    {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 3
        
        if let xPoint = formatter.string(from: NSNumber(value: Float(point.x) as Float))
        {
            if let yPoint = formatter.string(from: NSNumber(value: Float(point.y) as Float))
            {
                return " X = \(xPoint)\n Y = \(yPoint)"
            }
        }
        
        return "\(point)"
    }
    
    fileprivate func InitializePointLabel()
    {
        pointLabel.isUserInteractionEnabled = true
        pointLabel.adjustsFontSizeToFitWidth = true
        pointLabel.numberOfLines = 2
        addSubview(pointLabel)
    }
    
    internal func UpdatePointLabel(_ sender : UIGestureRecognizer)
    {
        SetPointLabelWithLocation(sender.location(in: self))
    }
    
    fileprivate func SetPointLabelWithLocation(_ touchLocation : CGPoint){
        pointLabel.isHidden = false
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
            pointLabel.frame.origin.x = UIScreen.main.bounds.size.width - 10 - pointLabel.frame.width
        }
        if pointLabel.frame.YOutOfBounds()
        {
            pointLabel.frame.origin.y = UIScreen.main.bounds.size.height - 10 - pointLabel.frame.height
        }
        
        pointLabel.text = labelText
        //position the cursor
    }
    
    func ConfigureMovePointLabel()
    {
        let moveLabelGesture = UIPanGestureRecognizer(target: self, action: #selector(MovePointLabel))
        pointLabel.addGestureRecognizer(moveLabelGesture)
    }
    
    func MovePointLabel(_ sender : UIPanGestureRecognizer)
    {
        pointLabel.frame.origin = sender.location(in: self)
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
        ConfigurePanGesture()
        AddTapToShowPointInfo()
        AddTapToHidePointLabel()
        ConfigureMovePointLabel()
        InitializePointLabel()
        AllSet = true
    }
    
    fileprivate let TickMarkerSize = 15 as CGFloat
    
    fileprivate func LongestDigits(_ left : Double, right : Double) -> (length : Int, number : Double){
        let leftLength = "\(left)".characters.count
        let rightLength = "\(right)".characters.count
        return leftLength > rightLength ? (leftLength, left) : (rightLength, right)
    }
    
    fileprivate func OptimalSkippingFactor(_ min : CGFloat, max : CGFloat, y : Bool) -> CGFloat
    {
        let greatestValue = (abs(min.description.Count) > abs(max.description.Count)) ? min : max
        
        let locationOfGreatestValue = y ? YPoint(Double(greatestValue)) : XPoint(Double(greatestValue))
        
        let attributedGreatestValue = NSAttributedString(string: greatestValue.description)
        let valueDimension = y ? ((attributedGreatestValue.size().height / 2) + 10) : ((attributedGreatestValue.size().width / 2) + 10)
        let greatestBounds : (lower : Double, upper : Double) = (locationOfGreatestValue - Double(valueDimension), locationOfGreatestValue + Double(valueDimension))
        let lowerBoundPoint = CGFloat(RectXPoint(greatestBounds.lower))
        let upperBoundPoint = CGFloat(RectXPoint(greatestBounds.upper))
        let newSkippingFactor = abs(upperBoundPoint - lowerBoundPoint)
        print("Skipping factor\(round(newSkippingFactor))")
        return round(newSkippingFactor)
    }
    
    fileprivate func ComputeOptimalSkippingFactor() -> CGFloat
    {
        return OptimalSkippingFactor(MinX, max: MaxX, y: false)
    }
    
    fileprivate func ComputeXTicks(_ XTicks : inout [GraphTick]){
        
        var previous : GraphTick?
        let Start = -(abs(MinX) - (abs(MinX).truncatingRemainder(dividingBy: XScale))) + 1
        
        var iterations = 0
        var skippingFactor = ComputeOptimalSkippingFactor()
        if skippingFactor <= 0{
            skippingFactor = XScale
        }
        print("The skipping factor is \(skippingFactor), starting at \(Start)")
        
        for CurrentX in stride(from: Start, to: MaxX, by: skippingFactor){
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
    
    fileprivate func ComputeYTicks(_ YTicks : inout [GraphTick]){
        var previous : GraphTick?
        let Start = -(abs(MinY) - (abs(MinY).truncatingRemainder(dividingBy: YScale))) + 1
        var iterations = 0
        
        var skippingFactor = OptimalSkippingFactor(MinY, max: MaxY, y: true)
        if skippingFactor <= 0{
            skippingFactor = YScale
        }

        for CurrentY in stride(from: Start, to: MaxY, by: skippingFactor){
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
    
    fileprivate func ComputeEquations(_ equations : [String]) -> ([Line], iterations : Int)
    {
        var ResultingEquations = [Line]()
        
        var num = 0
        
        for (i,equation) in equations.enumerated()
        {
            var CurrentEquation = Line(Expression: equation, numLines: i)
            
            let calculator = ExpressionEvaluator(expression: equation)
            
            let num_ticks = self.frame.size.width / 4
            let increment = (MaxX - MinX) / num_ticks
        
            for x in stride(from: Double(MinX), to: Double(MaxX), by: Double(increment)){
                calculator.SetVariableValue("x", value: x)
                let Point = PointForCoordinates(x, y: calculator.Result)
                CurrentEquation.AddPoint(Point)
                num += 1
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
    override func draw(_ rect: CGRect) {
        UIView.animate(withDuration: 0.5, animations: {
            UIColor.black.set()
            self.XAxis.stroke()
            self.YAxis.stroke()
            
            for tick in self.y_ticks{
                tick.draw()
            }
            for tick in self.x_ticks{
                tick.draw()
            }
            
            for line in self.lines { line.Draw() }
            
            //if !pointLabel.hidden { SetPointLabelWithLocation(pointLabel.frame.origin) }
            
            self.AllSet = false
            
            (self.delegate as? GraphViewDelegate)?.RenderingEnded(self.LastIterations)
        })
    }
    
    fileprivate func TickFormatter() -> NumberFormatter{
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 3
        return formatter
    }
        
    fileprivate func RectXPoint(_ XCoordinateInScreen : Double) -> Double
    {
        return (XCoordinateInScreen / Double(XTickWidth)) - Double(abs(MinX))
    }
    
    fileprivate func RectYPoint(_ YCoordinateInScreen : Double) -> Double
    {
        return Double(abs(MaxY)) - (YCoordinateInScreen / Double(YTickHeight))
    }
    
    internal func CoordinatesForPoint(_ XCoordinateInScreen : Double, YCoordinateInScreen : Double) -> CGPoint
    {
        return CGPoint(x: RectXPoint(XCoordinateInScreen), y: RectYPoint(YCoordinateInScreen))
    }
    
    internal func CoordinatesForPoint(point : CGPoint) -> CGPoint{
        return CoordinatesForPoint(Double(point.x), YCoordinateInScreen: Double(point.y))
    }
    
    fileprivate func ComputeXAxis(_ YLocation : CGFloat, AxisWidth : CGFloat, GraphWidth : CGFloat) -> UIBezierPath
    {
        let XAxis = UIBezierPath()
        
        XAxis.move(to: CGPoint(x: 0.0, y: YLocation))
        XAxis.addLine(to: CGPoint(x: GraphWidth, y: YLocation))
        XAxis.lineWidth = AxisWidth
        
        return XAxis
    }
    
    fileprivate func ComputeYAxis(_ XLocation : CGFloat, AxisWidth : CGFloat, GraphHeight : CGFloat) -> UIBezierPath
    {
        let YAxis = UIBezierPath()
        
        YAxis.move(to: CGPoint(x: XLocation, y: 0.0))
        YAxis.addLine(to: CGPoint(x: XLocation, y: GraphHeight))
        YAxis.lineWidth = AxisWidth
        
        return YAxis
    }
    
    fileprivate func XAxisStartLocation() -> Double
    {
        //we know that the minimum is at zero
        return Double(-1 * MinX * XTickWidth)
    }
    
    fileprivate func YAxisSstartLocation() -> Double
    {
        return Double(MaxY * YTickHeight)
    }
    
    fileprivate func XPoint(_ x : Double) -> Double
    {
        return XAxisStartLocation() + (Double(XTickWidth) * x)
    }
    
    fileprivate func YPoint(_ y : Double) -> Double
    {
        let start = YAxisSstartLocation()
        return start - (Double(YTickHeight) * y)
    }
    
    internal func PointForCoordinates(_ x : Double, y : Double) -> CGPoint
    {
        return CGPoint(x: XPoint(x), y: YPoint(y))
    }
    
    func LabelAttributedText(_ expression : String, index : Int, highlighted : Bool) -> NSAttributedString{
        let functionText = "Y\(index) = " + expression
        let attr_string = NSMutableAttributedString(string: functionText)
        let fontSize : CGFloat = 16
        if highlighted{
            attr_string.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: fontSize), range: NSRange(location: 0, length: expression.characters.count))
        }else{
            attr_string.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: 0, length: expression.characters.count))
        }
        return attr_string
    }
    
    fileprivate func UpdateFunctionLabel(_ expression : String, color : UIColor, i : Int)
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
        FunctionLabels[i].isUserInteractionEnabled = true
    }
    
    internal func HandleTapLabel(_ sender : UITapGestureRecognizer){
        if let text = (sender.view as? UILabel)?.text{
            if let number = NumberFormatter().number(from: "\(text[text.characters.index(text.startIndex, offsetBy: 1)])")?.intValue{
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
    
    func Zoom(_ scale : CGFloat){
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
    
    func ManagePinch(_ gesture : UIPinchGestureRecognizer)
    {
        print("Velocity :\(gesture.velocity)")
        
        if gesture.state == UIGestureRecognizerState.failed { return }

        let Scale = 1 / gesture.scale
        
        
        MaxX *= Scale
        MaxY *= Scale
        MinX *= Scale
        MinY *= Scale
        
        AllSet = true
        ReRender()
        
//        print("Scale is \(Scale)")
    }
    
    fileprivate func ConfigurePanGesture() {
        let PanGesture = UIPanGestureRecognizer(target: self, action: #selector(ManagePan))
        addGestureRecognizer(PanGesture)
    }
    
    func ManagePan(_ sender : UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: self)
        sender.setTranslation(CGPoint.zero, in: self)
        let startPoint = CoordinatesForPoint(point: CGPoint.zero)
        let endPoint = CoordinatesForPoint(point: translation)
        
        let difference = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        
        MaxX -= difference.x
        MinX -= difference.x
    
        MinY -= difference.y
        MaxY -= difference.y
        
        AllSet = true
        ReRender()
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
    Line.move(to: p1)
    Line.addLine(to: p2)
    Line.lineWidth = width
    return Line
}

infix operator +-


func +- (left : Double, right : Double) -> (left : Double, right : Double){
    return (left - right, left + right)
}





















