//
//  Equation.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 1/28/18.
//  Copyright © 2018 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class Equation {
    private(set) var equation = ""
    private(set) var points = [(x : Double, y : Double)]()
    
    init(equation : String){
        self.equation = equation
        self.points = [(Double, Double)]()
    }
    
    func addPoint(x : Double, y : Double){
        self.points.append((x,y))
    }
    
    func addPoint(point : (x : Double, y : Double)){
        self.addPoint(x: point.x, y: point.y)
    }
}

class VariableEquation : Equation{
    
}

class CustomPointEquation : Equation{
    
}
