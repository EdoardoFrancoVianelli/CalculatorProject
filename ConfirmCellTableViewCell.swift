//
//  ConfirmCellTableViewCell.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 1/26/18.
//  Copyright © 2018 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class ConfirmCellTableViewCell: UITableViewCell {

    @IBOutlet weak var cancelBackground: UIView!
    @IBOutlet weak var confirmBackground: UIView!
    @IBOutlet weak var cancelButton : UIButton?
    @IBOutlet weak var confirmButton : UIButton?
    
    @objc func dummyTapGesture(){
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(dummyTapGesture))
        confirmBackground.addGestureRecognizer(tap)
        cancelBackground.addGestureRecognizer(tap)
        confirmBackground.isUserInteractionEnabled = true
        cancelBackground.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
