//
//  RoundedView.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 1/24/18.
//  Copyright © 2018 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var cornerRadius : CGFloat {
        set{
            self.layer.cornerRadius = newValue
        }get{
            return self.layer.cornerRadius
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
