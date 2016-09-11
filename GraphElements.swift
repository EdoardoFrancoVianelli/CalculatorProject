//
//  GraphElement.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 8/3/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit

class GraphTick{
    
    private var _number = 0.0
    private var _number_location = CGPoint.zero{
        didSet{
            AttributedNumber = NSAttributedString(string: NumberString)
        }
    }
    private var _tick_path = UIBezierPath()
    private var y_tick = false
    private var AttributedNumber = NSAttributedString(string: ""){
        didSet{
            var origin = CGPoint(x: _number_location.x - AttributedNumber.size().width / 2, y: _number_location.y)
            if y_tick{
                origin = CGPoint(x: _number_location.x, y: _number_location.y - AttributedNumber.size().height / 2)
            }
            num_frame = CGRect(origin: origin, size: AttributedNumber.size())
        }
    }
    private var num_frame   = CGRect.zero
    
    var NumberFrame : CGRect { return num_frame }
    var NumberString : String { return TickFormatter().stringFromNumber(NSNumber(double: _number))! }
    var TickPath : UIBezierPath { return _tick_path }
    var NumberLocation : CGPoint { return _number_location }
    var Number : Double { return _number }
    
    init(number : Double, y : Bool) {
        _number = number
        SetYTick(y)
    }
    
    func SetYTick(val : Bool) { y_tick = val }
    
    func SetTickPath(start : CGPoint, end : CGPoint, width : CGFloat){
        _tick_path = LinePath(fromPoint: start, toPoint: end, width: width)
    }
    
    func draw(){
        UIColor.blackColor().set()
        AttributedNumber.drawAtPoint(NumberFrame.origin)
        TickPath.stroke()
    }
    
    func SetNumberLocation(location : CGPoint){
        _number_location = location
    }
    
    private func TickFormatter() -> NSNumberFormatter{
        let formatter = NSNumberFormatter()
        formatter.maximumSignificantDigits = 3
        return formatter
    }
}

class GraphElements{
    
    private var _x_axis  = UIBezierPath()
    private var _y_axis  = UIBezierPath()
    private var _x_ticks = [GraphTick]()
    private var _y_ticks = [GraphTick]()
    private var _lines   = [Line]()
    
    func AddTickToXTicks(tick : GraphTick) { _x_ticks.append(tick) }
    func AddTickToYTicks(tick : GraphTick) { _y_ticks.append(tick) }
    
    func SetXAxis(start : CGPoint, end : CGPoint, width : CGFloat)
    {
        _x_axis = LinePath(fromPoint: start, toPoint: end, width: width)
    }
    
    func SetYAxis(start : CGPoint, end : CGPoint, width : CGFloat)
    {
        _y_axis = LinePath(fromPoint: start, toPoint: end, width: width)
    }
    
    private func DrawAxis(color : UIColor, axis : UIBezierPath){
        color.set()
        axis.stroke()
    }
    
    func DrawXAxis(color : UIColor) { DrawAxis(color, axis: _x_axis) }
    func DrawYAxis(color : UIColor) { DrawAxis(color, axis: _y_axis) }
    
    func DrawLines(){
        for line in _lines{
            line.Draw()
        }
    }
    
    func AddLineToLines(line : Line){
        _lines.append(line)
    }
    
    func AddPointToLineAtIndex(point : CGPoint, index i : Int){
        if i < 0 || i >= _lines.count{
            return
        }
        _lines[i].AddPoint(point)
    }
}

struct Line {
    
    var width : CGFloat{
        get {
            return path.lineWidth
        }set{
            if newValue < 0 { return }
            path.lineWidth = newValue
        }
    }
    
    private var colors = [UIColor.redColor(),
                          UIColor.blackColor(),
                          UIColor.blueColor(),
                          UIColor.brownColor(),
                          UIColor.cyanColor(),
                          UIColor.grayColor(),
                          UIColor.greenColor(),
                          UIColor.lightGrayColor(),
                          UIColor.magentaColor(),
                          UIColor.orangeColor(),
                          UIColor.purpleColor()]
    private var _expression : String = ""
    private var _color : UIColor = UIColor.redColor()
    private var path = UIBezierPath()
    
    var Path : UIBezierPath {
        return path
    }
    
    var Expression : String{
        return _expression
    }
    
    var Color : UIColor{
        return _color
    }
    
    init(Expression : String, numLines : Int)
    {
        _expression = Expression
        _color = colors[numLines % colors.count]
        path = UIBezierPath()
    }
    
    func ResetPath() { path.removeAllPoints() }
    
    private var HasPoints = false
    
    mutating func AddPoint(point : CGPoint)
    {
        if !HasPoints
        {
            path.moveToPoint(point)
            HasPoints = true
        }else{
            path.addLineToPoint(point)
        }
    }
    
    func Draw() {
        _color.set()
        path.stroke()
    }
}






















