//
//  Settings.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 1/16/18.
//  Copyright © 2018 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class Settings{
    
    static func getSaved(_ name : String) -> Any?{
        return UserDefaults.standard.value(forKeyPath: name)
    }
    
    static func getSavedOrDefault(_ name : String, _ def : Any) -> Any{
        guard let saved = getSaved(name) else{
            return def
        }
        return saved
    }
    
    static func getSavedOrDefaultDouble(_ name : String, _ def : Double) -> Double{
        return getSavedOrDefault(name, def) as! Double
    }

    
    static func setSaved(_ name : String, _ value : Any) {
        UserDefaults.standard.set(value, forKey: name)
    }
    
    static var Y1 : String? {
        set{
            let toSave = newValue == nil ? "" : newValue!
            setSaved("Y1", toSave)
        }get{
            return getSaved("Y1") as? String
        }
    }
    static var Y2 : String? {
        set{
            let toSave = newValue == nil ? "" : newValue!
            setSaved("Y2", toSave)
        }get{
            return getSaved("Y2") as? String
        }
    }
    static var Y3 : String? {
        set{
            let toSave = newValue == nil ? "" : newValue!
            setSaved("Y3", toSave)
        }get{
            return getSaved("Y3") as? String
        }
    }
    static var Y4 : String? {
        set{
            let toSave = newValue == nil ? "" : newValue!
            setSaved("Y4", toSave)
        }get{
            return getSaved("Y4") as? String
        }
    }
    static var Y5 : String? {
        set{
            let toSave = newValue == nil ? "" : newValue!
            setSaved("Y5", toSave)
        }get{
            return getSaved("Y5") as? String
        }
    }
    static var Y6 : String? {
        set{
            let toSave = newValue == nil ? "" : newValue!
            setSaved("Y6", toSave)
        }get{
            return getSaved("Y6") as? String
        }
    }
    
    static var XScale : Double {
        set {
            setSaved("XScale", newValue)
        }get {
            return getSavedOrDefaultDouble("XScale", 1.0)
        }
    }
    
    static var XMin : Double {
        set {
            setSaved("XMin", newValue)
        }get{
            return getSavedOrDefaultDouble("XMin", -10)
        }
    }
    
    static var XMax : Double {
        set {
            setSaved("XMax", newValue)
        }get{
            return getSavedOrDefaultDouble("XMax", 10)
        }
    }
    
    static var YScale : Double {
        set {
            setSaved("YScale", newValue)
        }get{
            return getSavedOrDefaultDouble("YScale", 1)
        }
    }
    
    static var YMin : Double {
        set {
            setSaved("YMin", newValue)
        }get{
            return getSavedOrDefaultDouble("YMin", -10)
        }
    }
    
    static var YMax : Double  {
        set {
            setSaved("YMax", newValue)
        }get{
            return getSavedOrDefaultDouble("YMax", 10)
        }
    }
    
    static var allEquations : [String : String] {
        get{
            var all = [String : String]()
            let equationNames = ["Y1","Y2","Y3","Y4","Y5","Y6"]
            let equations = [Y1,Y2,Y3,Y4,Y5,Y6]
            for i in 0..<6{
                let equationSet : (name : String, equation : String?) = (equationNames[i], equations[i])
                if let currentEquation = equationSet.equation{
                    if currentEquation != ""{
                        all[equationSet.name] = currentEquation
                    }
                }
            }
            return all
        }
    }
}











