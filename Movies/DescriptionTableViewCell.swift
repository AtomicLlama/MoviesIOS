//
//  DescriptionTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    // Yeah, I'm not commenting this.
    
    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            backgroundColor = UIColor.clearColor()
        }
    }
    
}
