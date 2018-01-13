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
    
    fileprivate var _number = 0.0
    fileprivate var _number_location = CGPoint.zero{
        didSet{
            AttributedNumber = NSAttributedString(string: NumberString)
        }
    }
    fileprivate var _tick_path = UIBezierPath()
    fileprivate var y_tick = false
    fileprivate var AttributedNumber = NSAttributedString(string: ""){
        didSet{
            var origin = CGPoint(x: _number_location.x - AttributedNumber.size().width / 2, y: _number_location.y)
            if y_tick{
                origin = CGPoint(x: _number_location.x, y: _number_location.y - AttributedNumber.size().height / 2)
            }
            num_frame = CGRect(origin: origin, size: AttributedNumber.size())
        }
    }
    fileprivate var num_frame   = CGRect.zero
    
    var NumberFrame : CGRect { return num_frame }
    var NumberString : String { return TickFormatter().string(from: NSNumber(value: _number as Double))! }
    var TickPath : UIBezierPath { return _tick_path }
    var NumberLocation : CGPoint { return _number_location }
    var Number : Double { return _number }
    
    init(number : Double, y : Bool) {
        _number = number
        SetYTick(y)
    }
    
    func SetYTick(_ val : Bool) { y_tick = val }
    
    func SetTickPath(_ start : CGPoint, end : CGPoint, width : CGFloat){
        _tick_path = LinePath(fromPoint: start, toPoint: end, width: width)
    }
    
    func draw(){
        UIColor.black.set()
        AttributedNumber.draw(at: NumberFrame.origin)
        TickPath.stroke()
    }
    
    func SetNumberLocation(_ location : CGPoint){
        _number_location = location
    }
    
    fileprivate func TickFormatter() -> NumberFormatter{
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 3
        return formatter
    }
}

class GraphElements{
    
    fileprivate var _x_axis  = UIBezierPath()
    fileprivate var _y_axis  = UIBezierPath()
    fileprivate var _x_ticks = [GraphTick]()
    fileprivate var _y_ticks = [GraphTick]()
    fileprivate var _lines   = [Line]()
    
    func AddTickToXTicks(_ tick : GraphTick) { _x_ticks.append(tick) }
    func AddTickToYTicks(_ tick : GraphTick) { _y_ticks.append(tick) }
    
    func SetXAxis(_ start : CGPoint, end : CGPoint, width : CGFloat)
    {
        _x_axis = LinePath(fromPoint: start, toPoint: end, width: width)
    }
    
    func SetYAxis(_ start : CGPoint, end : CGPoint, width : CGFloat)
    {
        _y_axis = LinePath(fromPoint: start, toPoint: end, width: width)
    }
    
    fileprivate func DrawAxis(_ color : UIColor, axis : UIBezierPath){
        color.set()
        axis.stroke()
    }
    
    func DrawXAxis(_ color : UIColor) { DrawAxis(color, axis: _x_axis) }
    func DrawYAxis(_ color : UIColor) { DrawAxis(color, axis: _y_axis) }
    
    func DrawLines(){
        for line in _lines{
            line.Draw()
        }
    }
    
    func AddLineToLines(_ line : Line){
        _lines.append(line)
    }
    
    func AddPointToLineAtIndex(_ point : CGPoint, index i : Int){
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
    
    fileprivate var colors = [UIColor.red,
                          UIColor.black,
                          UIColor.blue,
                          UIColor.brown,
                          UIColor.cyan,
                          UIColor.gray,
                          UIColor.green,
                          UIColor.lightGray,
                          UIColor.magenta,
                          UIColor.orange,
                          UIColor.purple]
    fileprivate var _expression : String = ""
    fileprivate var _color : UIColor = UIColor.red
    fileprivate var path = UIBezierPath()
    
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
    
    fileprivate var HasPoints = false
    
    mutating func AddPoint(_ point : CGPoint)
    {
        if !HasPoints
        {
            path.move(to: point)
            HasPoints = true
        }else{
            path.addLine(to: point)
        }
    }
    
    func Draw() {
        _color.set()
        path.stroke()
    }
}






















