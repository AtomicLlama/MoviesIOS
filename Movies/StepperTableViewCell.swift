//
//  StepperTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 1/23/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit
import GMStepper

class StepperTableViewCell: UITableViewCell {

    @IBOutlet weak var stepper: GMStepper!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
