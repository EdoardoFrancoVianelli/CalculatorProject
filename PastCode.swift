//
//  PastCode.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 8/18/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

//    private func DrawLabelForTickAtPoint(number            : CGFloat,
//                                         point             : CGPoint,
//                                         y                 : Bool,
//                                         previous          : CGRect) -> (dimensions : CGRect, intersected : Bool)
//    {
//        let NumberToPrint = TickFormatter().numberFromString(number.description)!.description
//
//        var xLocation : CGFloat = point.x - CGFloat(10)
//        var yLocation : CGFloat = point.y + 10
//        if y {
//            xLocation = point.x + CGFloat(10)
//            yLocation -= 17
//        }
//
//        let location = CGPoint(x: xLocation, y: yLocation)
//        let str = NSAttributedString(string: NumberToPrint)
//        let dimensions = CGRect(origin: location, size: str.size())
//
//        let intersected = dimensions.intersects(previous)
//
//        if !intersected
//        {
//            str.drawAtPoint(location)
//        }
//        if !y {
//            let newDimensions = CGRect(origin: point, size: str.size())
//            return (newDimensions, intersected)
//        }
//
//        return (dimensions, intersected)
//    }
//
//    private func DrawXTics()
//    {
//        let XTickWidthLocal : CGFloat = 15
//        var previous = CGRect.zero
//        let Start = -(abs(MinX) - (abs(MinX) % XScale)) + 1
//        for i in Start.stride(to: MaxX, by: XScale)
//        {
//            let Point       = PointForCoordinates(Double(i), y: 0.0)
//            //draw the label with the current number
//            let current = DrawLabelForTickAtPoint(i, point: Point, y: false, previous: previous)
//            if !(current.intersected){
//                previous = current.dimensions
//                let FirstPoint  = CGPoint(x: Point.x, y:  Point.y - XTickWidthLocal / 2)
//                let SecondPoint = CGPoint(x: Point.x, y:  Point.y + XTickWidthLocal / 2)
//                LinePath(fromPoint: FirstPoint, toPoint: SecondPoint, width: AxisWidth).stroke()
//            }
//        }
//    }
//
//    private func DrawYTics()
//    {
//
//        let YTickHeightLocal : CGFloat = 15
//        var previous = CGRect.zero
//        let Start = MinY
//        for i in Start.stride(to: MaxY, by: YScale)
//        {
//            let Point       = PointForCoordinates(0.0, y: Double(i))
//            let current = DrawLabelForTickAtPoint(i, point: Point, y: true, previous: previous)
//            if !(current.intersected) {
//                previous = current.dimensions
//                let FirstPoint  = CGPoint(x: Point.x  -  YTickHeightLocal / 2, y: Point.y)
//                let SecondPoint = CGPoint(x: Point.x  +  YTickHeightLocal / 2, y:  Point.y)
//                LinePath(fromPoint: FirstPoint, toPoint: SecondPoint, width: AxisWidth).stroke()
//            }else{
//                print("Intersected for \(i)")
//            }
//        }
//    }
