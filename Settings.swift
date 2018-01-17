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
            return getSavedOrDefaultDouble("YMax", -10)
        }
    }
    
}
