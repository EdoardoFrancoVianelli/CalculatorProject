//
//  MoreTableViewCell.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 7/8/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet var TextField : UITextField!
    @IBOutlet var Label : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
