//
//  StreamingItemTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 5/16/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit

class StreamingItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView! {
        didSet {
            self.backgroundColor = UIColor.clearColor()
            posterView.clipsToBounds = true
        }
    }
    
    var service: String? {
        didSet {
            titleLabel.text = service
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
