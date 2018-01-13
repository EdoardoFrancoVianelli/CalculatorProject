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
    func XScaleChanged(_ newXScale : Double)
    func XMinChanged(_ newXMin : Double)
    func XMaxChanged(_ newXMax : Double)
    func YScaleChanged(_ newYScale : Double)
    func YMinChanged(_ newYMin : Double)
    func YMaxChanged(_ newYMax : Double)
}

class MoreModel {
    var delegate : MoreModelDelegate?
    
    fileprivate var _XScale = 1.0 { didSet { delegate?.XScaleChanged(XScale) } }
    fileprivate var _XMin = -10.0 { didSet { delegate?.XMinChanged(XMin) } }
    fileprivate var _XMax = 10.0  { didSet { delegate?.XMaxChanged(XMax) } }
    fileprivate var _YScale = 1.0 { didSet { delegate?.YScaleChanged(YScale) } }
    fileprivate var _YMin = -10.0 { didSet { delegate?.YMinChanged(YMin) } }
    fileprivate var _YMax = 10.0  { didSet { delegate?.YMaxChanged(YMax) } }
    
    
    var XScale = 1.0 { didSet { delegate?.XScaleChanged(XScale) } }
    var XMin = -10.0 { didSet { delegate?.XMinChanged(XMin) } }
    var XMax = 10.0  { didSet { delegate?.XMaxChanged(XMax) } }
    var YScale = 1.0 { didSet { delegate?.YScaleChanged(YScale) } }
    var YMin = -10.0 { didSet { delegate?.YMinChanged(YMin) } }
    var YMax = 10.0  { didSet { delegate?.YMaxChanged(YMax) } }
}
