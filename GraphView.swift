//
//  GraphView.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

protocol GraphViewControllerDelegate{
    func GraphViewDidAppear(newXMax : Double,
                            newXMin : Double,
                            newXScale : Double,
                            newYMax : Double,
                            newYMin : Double,
                            newYScale : Double,
                            equations : [String : String])
}

protocol GraphViewDelegate{
    func RenderingStarted()
    func RenderingEnded(_ iterations : Int)
    func minXDidChange(minX : CGFloat)
    func maxXDidChange(maxX : CGFloat)
    func xScaleDidChange(xScale : CGFloat)
    func minYDidChange(minY : CGFloat)
    func maxYDidChange(maxY : CGFloat)
    func yScaleDidChange(yScale : CGFloat)
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

@IBDesignable
class GraphView: UIView, GraphViewControllerDelegate {
    
    private var FrameLimits = GraphBounds()
    
    override var bounds: CGRect{ didSet{ AllSet = true } }
    
    @IBInspectable
    var MinX : CGFloat {
        get{
            return CGFloat(FrameLimits.MinX)
        }set{
            FrameLimits.MinX = Float(newValue)
            (delegate as? GraphViewDelegate)?.minXDidChange(minX: MinX)
        }
    }
    
    @IBInspectable
    var MaxX : CGFloat {
        get{
            return CGFloat(FrameLimits.MaxX)
        }
        set{
            FrameLimits.MaxX = Float(newValue)
            (delegate as? GraphViewDelegate)?.maxXDidChange(maxX: MaxX)
        }
    }
    
    @IBInspectable
    var MinY : CGFloat {
        get{
            return CGFloat(FrameLimits.MinY)
        }
        set{
            FrameLimits.MinY = Float(newValue)
            (delegate as? GraphViewDelegate)?.minYDidChange(minY: MinY)
        }
    }
    
    @IBInspectable
    var MaxY : CGFloat {
        get{
            return CGFloat(FrameLimits.MaxY)
        }
        set{
            FrameLimits.MaxY = Float(newValue)
            (delegate as? GraphViewDelegate)?.maxYDidChange(maxY: MaxY)
        }
    }
    
    @IBInspectable
    var AxisWidth : CGFloat = 4.0
    
    @IBInspectable
    var XScale : CGFloat {
        get{
            return CGFloat(FrameLimits.XScale)
        }
        set{
            FrameLimits.XScale = Float(newValue)
            (delegate as? GraphViewDelegate)?.xScaleDidChange(xScale: XScale)
        }
    }

    @IBInspectable
    var YScale : CGFloat {
        get{
            return CGFloat(FrameLimits.YScale)
        }
        set{
            FrameLimits.YScale = Float(newValue)
            (delegate as? GraphViewDelegate)?.yScaleDidChange(yScale: YScale)
        }
    }
    
    var AllSet : Bool = false{
        didSet {
            if AllSet {
                ReRender()
            }
        }
    }
    
    private var expressions = [String:String]()
    
    fileprivate var LastIterations = 0
    
    fileprivate func ReRender()
    {
        if AllSet
        {
            (delegate as? GraphViewDelegate)?.RenderingStarted()
            RenewTickDimensions()
            ComputeAxes()
            ComputeTicks()
            Grid = ComputeGrid(ticks: y_ticks + x_ticks)
            
            let numTicks = Int(self.bounds.size.width / 4)
            
            let equations = ComposeEquations(forFunction: self.expressions, withNumberOfPoints: numTicks)
            lines = ComposeLines(equations: equations)
            
            self.setNeedsDisplay()
        }
    }
    
    fileprivate var XTickWidth : CGFloat = 0.0
    fileprivate var YTickHeight : CGFloat = 0.0
    
    fileprivate var XAxis = UIBezierPath()
    fileprivate var YAxis = UIBezierPath()
    
    fileprivate var x_ticks = [GraphTick]()
    fileprivate var y_ticks = [GraphTick]()
    
    fileprivate var Grid = [UIBezierPath]()
    
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
        return self.bounds.size.width / MinMaxDifference
    }
    
    fileprivate func GetYTickHeight() -> CGFloat
    {
        let MinMaxDifference = YMinMaxDifference()
        return self.bounds.size.height / MinMaxDifference
    }
    
    fileprivate func RenewTickDimensions()
    {
        (XTickWidth, YTickHeight) = (GetXTickWidth(), GetYTickHeight())
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
    
    @objc internal func TogglePointLabel(_ sender : UITapGestureRecognizer){
        if let hidden = sender.view?.isHidden{
            sender.view?.isHidden = !hidden
            pointCursor.isHidden = true
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
    
    let pointCursorDimension : CGFloat = 10
    
    fileprivate func InitializePointLabelAndCursor()
    {
        /*INITIALIZE POINT LABEL*/
        pointLabel.isUserInteractionEnabled = true
        pointLabel.adjustsFontSizeToFitWidth = true
        pointLabel.numberOfLines = 2
        addSubview(pointLabel)
        
        /*INITIALIZE CURSOR*/
        
        pointCursor.backgroundColor = UIColor.black
        pointCursor.layer.cornerRadius = pointCursorDimension / 2
        addSubview(pointCursor)
    }
    
    @objc internal func UpdatePointLabel(_ sender : UIGestureRecognizer)
    {
        SetPointLabelWithLocation(sender.location(in: self))
    }
    
    var pointCursor = UIView()
    
    fileprivate func SetPointLabelWithLocation(_ touchLocation : CGPoint){
        
        pointCursor.isHidden = false
        let XYPoint = CoordinatesForPoint(Double(touchLocation.x), YCoordinateInScreen: Double(touchLocation.y))
        let labelText = PointToString(XYPoint)
        let labelHeight : CGFloat = 80
        var labelWidth : CGFloat = CGFloat( (labelText.count / 2 ) * 10)
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
        pointCursor.frame.origin = CGPoint(x: touchLocation.x - pointCursorDimension / 2, y: touchLocation.y - pointCursorDimension / 2)
        pointCursor.frame.size = CGSize(width: pointCursorDimension, height: pointCursorDimension)
        
        pointCursor.isHidden = false
    }
    
    func ConfigureMovePointLabel()
    {
        let moveLabelGesture = UIPanGestureRecognizer(target: self, action: #selector(MovePointLabel))
        pointLabel.addGestureRecognizer(moveLabelGesture)
    }
    
    @objc func MovePointLabel(_ sender : UIPanGestureRecognizer)
    {
        pointLabel.frame.origin = sender.location(in: self)
        UpdatePointLabel(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        AllSet = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Initialize()
    }
    
    func Initialize()
    {
        AddTapToShowPointInfo()
        AddTapToHidePointLabel()
        ConfigureMovePointLabel()
        InitializePointLabelAndCursor()
        AllSet = true
    }
    
    fileprivate func LongestDigits(_ left : Double, right : Double) -> (length : Int, number : Double){
        let leftLength = "\(left)".count
        let rightLength = "\(right)".count
        return leftLength > rightLength ? (leftLength, left) : (rightLength, right)
    }
    
    fileprivate func OptimalSkippingFactor(_ min : CGFloat, max : CGFloat, y : Bool) -> CGFloat
    {
        let greatestValue = (abs(min.description.count) > abs(max.description.count)) ? min : max
        let locationOfGreatestValue = y ? YPoint(Double(greatestValue)) : XPoint(Double(greatestValue))
        let attributedGreatestValue = NSAttributedString(string: greatestValue.description)
        let valueDimension = y ? ((attributedGreatestValue.size().height / 2) + 10) : ((attributedGreatestValue.size().width / 2) + 10)
        let greatestBounds : (lower : Double, upper : Double) = (locationOfGreatestValue - Double(valueDimension), locationOfGreatestValue + Double(valueDimension))
        let lowerBoundPoint = CGFloat(!y ? RectXPoint(greatestBounds.lower) : RectYPoint(greatestBounds.lower))
        let upperBoundPoint = CGFloat(!y ? RectXPoint(greatestBounds.upper) : RectYPoint(greatestBounds.upper))
        let newSkippingFactor = abs(upperBoundPoint - lowerBoundPoint)
        print("Skipping factor\(round(newSkippingFactor))")
        return round(newSkippingFactor)
    }
    
    fileprivate func ComputeOptimalSkippingFactor() -> CGFloat
    {
        return OptimalSkippingFactor(MinX, max: MaxX, y: false)
    }
    
    fileprivate func ComputeTicks(x : Bool) -> [GraphTick]{
        
        var Ticks = [GraphTick]()
        
        let min = x ? MinX : MinY
        let max = x ? MaxX : MaxY
        let scale = x ? XScale : YScale
        
        var previous : GraphTick?
        let Start = -(abs(min) - (abs(min).truncatingRemainder(dividingBy: scale)))// + 1
        
        var iterations = 0
        var skippingFactor = ComputeOptimalSkippingFactor()
        if skippingFactor <= 0{
            skippingFactor = scale
        }
        print("The skipping factor is \(skippingFactor), starting at \(Start)")
        
        for Current in stride(from: Start, to: max, by: skippingFactor / 5){
            
            if Current == 0{
                iterations += 1
                continue
            }
            
            let x_coord = x ? Double(Current) : 0.0
            let y_coord = x ? 0.0 : Double(Current)
            let ScreenCoordinates = PointForCoordinates(x: x_coord, y: y_coord)
            let CurrentTick = GraphTick(number: x ? x_coord : y_coord, y: !x)
            //TODO: modify from here
            let hasNumber = (iterations % 5 == 0)
            let standardSize : CGFloat = 15
            let TickMarkerSize : CGFloat = hasNumber ? standardSize : standardSize / 4
            if x {
                let StartPoint = CGPoint(x: ScreenCoordinates.x, y: ScreenCoordinates.y - TickMarkerSize / 2)
                let EndPoint = CGPoint(x: StartPoint.x, y: StartPoint.y + TickMarkerSize)
                CurrentTick.SetTickPath(StartPoint, end: EndPoint, width: AxisWidth)
                if hasNumber{
                    CurrentTick.SetNumberLocation(CGPoint(x: EndPoint.x - CurrentTick.NumberFrame.size.width, y: EndPoint.y + 5))
                }
            } else {
                let StartPoint = CGPoint(x: ScreenCoordinates.x - TickMarkerSize / 2, y: ScreenCoordinates.y)
                let EndPoint = CGPoint(x: StartPoint.x + TickMarkerSize, y: StartPoint.y)
                CurrentTick.SetTickPath(StartPoint, end: EndPoint, width: AxisWidth)
                if hasNumber {
                    CurrentTick.SetNumberLocation(CGPoint(x: EndPoint.x + TickMarkerSize / 2 , y: EndPoint.y - CurrentTick.NumberFrame.size.height / 2))
                }
            }
            if let prev = previous{
                //let xDifference = abs((prev.NumberFrame.origin.x + prev.NumberFrame.size.width) - CurrentTick.NumberFrame.origin.x)
                if !prev.NumberFrame.intersects(CurrentTick.NumberFrame) || !hasNumber{
                    Ticks.append(CurrentTick)
                    previous = CurrentTick
                }
            }else{
                Ticks.append(CurrentTick)
                previous = CurrentTick
            }
            iterations += 1
        }
        
        print("Iterations for x ticks is \(iterations)")
        return Ticks
    }
    
    /**Takes an equation array with (x,y) points and converts it into a line array with screen points*/
    fileprivate func ComposeLines(equations : [Equation]) -> [Line]{
        var ResultingEquations = [Line]()

        for (i, equation) in equations.enumerated(){
            var CurrentEquation = Line(Expression: equation.equation, numLines: i)
            for point in equation.points{
                let Point = PointForCoordinates(x: point.x, y: point.y)
                CurrentEquation.AddPoint(Point)
            }
            ResultingEquations.append(CurrentEquation)
        }
        
        return ResultingEquations
    }
    
    fileprivate func ComposeEquations(forFunction functions : [String : String], withNumberOfPoints num_ticks : Int) -> [Equation]{
         var allEquations = [Equation]()
         
         let increment = (MaxX - MinX) / CGFloat(num_ticks)
         
         for function in functions
         {
            let expression = function.value
            let currentEquation = Equation(equation: expression)
            for x in stride(from: Double(MinX), to: Double(MaxX), by: Double(increment)){
                let calculator = Expression(expression,
                                            options: [],
                                            constants: [:],
                                            arrays: [:],
                                            symbols: [Expression.Symbol.variable("x"):{ _ in x }])
                do {
                    let result = try calculator.evaluate()
                    currentEquation.addPoint(x: x, y: result)
                }catch{
                    continue
                }
            }
            allEquations.append(currentEquation)
         }
         
        return allEquations
    }
    
    func ComputeGrid(ticks : [GraphTick]) -> [UIBezierPath]{
        var allGridGuides = [UIBezierPath]()
        for tick in ticks{
            let currentGuidePath = UIBezierPath()
            currentGuidePath.lineWidth = AxisWidth / 4
            var startPoint : (x : Double, y : Double) = (Double(MinX), tick.Number)
            var secondPoint : (x : Double, y : Double) = (Double(MaxX), tick.Number)
            var firstCoordinate = PointForCoordinates(x: startPoint.x, y: startPoint.y)
            var secondCoordinate = PointForCoordinates(x: secondPoint.x, y: secondPoint.y)
            if !tick.YTick { //need to draw vertically
                startPoint = (tick.Number, Double(MaxY))
                secondPoint = (tick.Number, Double(MinY))
                firstCoordinate = PointForCoordinates(x: startPoint.x, y: startPoint.y)
                secondCoordinate = PointForCoordinates(x: secondPoint.x, y: secondPoint.y)
            }
            currentGuidePath.move(to: firstCoordinate)
            currentGuidePath.addLine(to: secondCoordinate)
            allGridGuides.append(currentGuidePath)
        }
        return allGridGuides
    }
    
    let cursorDimension : CGFloat = 30
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        UIColor.black.set()
        self.XAxis.stroke()
        self.YAxis.stroke()
        
        for tick in self.y_ticks{
            tick.draw()
        }
        for tick in self.x_ticks{
            tick.draw()
        }
        
        for guide in Grid{
            UIColor.gray.set()
            guide.stroke()
        }
        
        UIColor.black.set()
        
        for line in self.lines { line.Draw() }
        
        //if !pointLabel.hidden { SetPointLabelWithLocation(pointLabel.frame.origin) }
        
        self.AllSet = false
        
        (self.delegate as? GraphViewDelegate)?.RenderingEnded(self.LastIterations)
        
        //CLEAN UP SOME MEMORY
        
        self.XAxis = UIBezierPath()
        self.YAxis = UIBezierPath()
        self.Grid = [UIBezierPath]()
        self.lines = [Line]()
    }
    
    private func expressionsAltered(original : [String : String], new : [String : String]) -> Bool{
        for expressionElement in new{
            if !(original[expressionElement.key] == new[expressionElement.key]){
                return true
            }
        }
        return false
    }
        
    func GraphViewDidAppear(newXMax : Double,
                            newXMin : Double,
                            newXScale : Double,
                            newYMax : Double,
                            newYMin : Double,
                            newYScale : Double,
                            equations : [String : String]) {
        
        print("Updating parameters...")
        
        let newXMax_f = CGFloat(newXMax)
        let newXMin_f = CGFloat(newXMin)
        let newXScale_f = CGFloat(newXScale)
        let newYMax_f = CGFloat(newYMax)
        let newYMin_f = CGFloat(newYMin)
        let newYScale_f = CGFloat(newYScale)
        
        var parameter_changed = false
        
        if newXMax_f != MaxX{
            MaxX = newXMax_f
            parameter_changed = true
        }
        if newXMin_f != MinX{
            MinX = newXMin_f
            parameter_changed = true
        }
        if newXScale_f != XScale{
            XScale = newXScale_f
            parameter_changed = true
        }
        if newYMax_f != MaxY{
            MaxY = newYMax_f
            parameter_changed = true
        }
        if newYMin_f != MinY{
            MinY = newYMin_f
            parameter_changed = true
        }
        if newYScale_f != YScale{
            YScale = newYScale_f
            parameter_changed = true
        }
        
        if expressionsAltered(original: self.expressions, new: equations){
            self.expressions = equations
            parameter_changed = true
        }
        
        if parameter_changed{
            AllSet = true
        }
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
    
    fileprivate func ComputeAxes(){
        XAxis = ComputeAxis(withStartingLocation: PointForCoordinates(x: Double(MinX), y: 0.0), withWidth: AxisWidth, andLength: frame.size.width, forY: false)
        YAxis = ComputeAxis(withStartingLocation: PointForCoordinates(x: 0.0, y: Double(MinY)), withWidth: AxisWidth, andLength: frame.size.height, forY: true)
    }
    
    fileprivate func ComputeTicks(){
        x_ticks = ComputeTicks(x: true)
        y_ticks = ComputeTicks(x: false)
    }
    
    fileprivate func ComputeAxis(withStartingLocation startingLocation : CGPoint,
                                 withWidth width : CGFloat,
                                 andLength length : CGFloat,
                                 forY Y : Bool) -> UIBezierPath
    {
        let axis = UIBezierPath()
        axis.move(to: startingLocation)
        let destination = Y ? CGPoint(x: startingLocation.x, y: startingLocation.y - length) : CGPoint(x: startingLocation.x + length, y: startingLocation.y)
        axis.addLine(to: destination)
        axis.lineWidth = width
        return axis
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
        let unadjusted_point = (XAxisStartLocation() + (Double(XTickWidth) * x))
        return unadjusted_point
    }
    
    fileprivate func YPoint(_ y : Double) -> Double
    {
        let start = YAxisSstartLocation()
        let unadjusted_point = (start - (Double(YTickHeight) * y))
        
        return unadjusted_point
        /*
        
        if y < 0{
            return unadjusted_point * Double(YScale)
        }
        
        return unadjusted_point / Double(YScale)
         */
    }
    
    internal func PointForCoordinates(x : Double, y : Double) -> CGPoint
    {
        return CGPoint(x: XPoint(x), y: YPoint(y))
    }
    
    func LabelAttributedText(_ expression : String, index : Int, highlighted : Bool) -> NSAttributedString{
        let functionText = "Y\(index) = " + expression
        let attr_string = NSMutableAttributedString(string: functionText)
        let fontSize : CGFloat = 16
        if highlighted{
            attr_string.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: fontSize), range: NSRange(location: 0, length: expression.count))
        }else{
            attr_string.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: 0, length: expression.count))
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
        FunctionLabels[i].frame.origin = CGPoint(x: 10, y: 20 + 25 * i)
        FunctionLabels[i].frame.size = CGSize(width: CGFloat(attributedText.string.count) * 10, height: 30)
        FunctionLabels[i].attributedText = attributedText
        FunctionLabels[i].textColor = color
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(HandleTapLabel))
        tapAction.numberOfTapsRequired = 1
        FunctionLabels[i].addGestureRecognizer(tapAction)
        FunctionLabels[i].isUserInteractionEnabled = true
    }
    
    @objc internal func HandleTapLabel(_ sender : UITapGestureRecognizer){
        if let text = (sender.view as? UILabel)?.text{
            if let number = NumberFormatter().number(from: "\(text[text.index(text.startIndex, offsetBy: 1)])")?.intValue{
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











/*
 
 //MARK: Gesture Stuff
 
 func ConfigurePinchGesture()
 {
 let PinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ManagePinch))
 self.addGestureRecognizer(PinchGesture)
 }
 
 @objc func ManagePinch(_ gesture : UIPinchGestureRecognizer)
 {
 print("Velocity :\(gesture.velocity)")
 
 if gesture.state == UIGestureRecognizerState.failed { return }
 
 let Scale = 1 / gesture.scale
 
 
 MaxX *= Scale
 MaxY *= Scale
 MinX *= Scale
 MinY *= Scale
 
 AllSet = true
 
 //        print("Scale is \(Scale)")
 }
 
 fileprivate func ConfigurePanGesture() {
 let PanGesture = UIPanGestureRecognizer(target: self, action: #selector(ManagePan))
 addGestureRecognizer(PanGesture)
 }
 
 @objc func ManagePan(_ sender : UIPanGestureRecognizer)
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
 }
 
 */















