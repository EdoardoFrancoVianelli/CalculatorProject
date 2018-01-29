//
//  Line.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 1/28/18.
//  Copyright © 2018 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit

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

