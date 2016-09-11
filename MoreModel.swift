//
//  MoreModel.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 7/31/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit

protocol MoreModelDelegate{
    func XScaleChanged(newXScale : Double)
    func XMinChanged(newXMin : Double)
    func XMaxChanged(newXMax : Double)
    func YScaleChanged(newYScale : Double)
    func YMinChanged(newYMin : Double)
    func YMaxChanged(newYMax : Double)
}

class MoreModel {
    var delegate : MoreModelDelegate?
    
    private var _XScale = 1.0 { didSet { delegate?.XScaleChanged(XScale) } }
    private var _XMin = -10.0 { didSet { delegate?.XMinChanged(XMin) } }
    private var _XMax = 10.0  { didSet { delegate?.XMaxChanged(XMax) } }
    private var _YScale = 1.0 { didSet { delegate?.YScaleChanged(YScale) } }
    private var _YMin = -10.0 { didSet { delegate?.YMinChanged(YMin) } }
    private var _YMax = 10.0  { didSet { delegate?.YMaxChanged(YMax) } }
    
    
    var XScale = 1.0 { didSet { delegate?.XScaleChanged(XScale) } }
    var XMin = -10.0 { didSet { delegate?.XMinChanged(XMin) } }
    var XMax = 10.0  { didSet { delegate?.XMaxChanged(XMax) } }
    var YScale = 1.0 { didSet { delegate?.YScaleChanged(YScale) } }
    var YMin = -10.0 { didSet { delegate?.YMinChanged(YMin) } }
    var YMax = 10.0  { didSet { delegate?.YMaxChanged(YMax) } }
}