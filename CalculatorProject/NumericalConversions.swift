//
//  NumericalConversions.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/23/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

extension String
{

    var IntegerValue : Int?{
        get{
            
            let conversionTable : Dictionary<Character, Int> = ["1" : 1,
                                                                "2" : 2, "3" : 3,
                                                                "4" : 4, "5" : 5,
                                                                "6" : 6, "7" : 7,
                                                                "8" : 8, "9" : 9]
            var start = startIndex
            var negative = false
            var result = 0
            
            if characters.first == "-"{
                start = start.successor()
                negative = true
            }
            
            for i in start..<endIndex{
                let c = self[i]
                if let cValue = conversionTable[c]{
                    result *= 10
                    result += cValue
                }else{
                    return nil
                }
            }
            
            if negative { result *= -1 }
            
            return result
        }
    }


}