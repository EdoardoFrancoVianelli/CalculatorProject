//
//  ConfirmCellTableViewCell.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 1/26/18.
//  Copyright © 2018 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class ConfirmCellTableViewCell: UITableViewCell {

    @IBOutlet weak var cancelButton : UIButton?
    @IBOutlet weak var confirmButton : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
